from flask import Flask, request, jsonify, Blueprint
import sqlite3
import requests
import jwt
from functools import wraps
from werkzeug.security import check_password_hash
from datetime import datetime, timedelta
from modules.chat.init_chat_db import init_chat_db
from modules.chat.users_credentials_verification_from_db import verify_user_credentials
from modules.chat.check_user_exist_from_db import check_user_exists

conversation = Blueprint('conversation', __name__)

# Configuration - UPDATED to match login_jwt.py
CHAT_DATABASE = 'chat.db'
USER_API_URL = 'http://localhost:5000'  # User registration API URL
AUTH_API_URL = 'http://localhost:3000'  # Authentication API URL
JWT_SECRET_KEY = 'your-secret-key-change-this-in-production'  # Must match login_jwt.py

def token_required(f):
    """Decorator to verify JWT token - Updated to match login_jwt.py"""
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization')

        if not auth_header:
            return jsonify({'error': 'Authorization header is missing'}), 401

        if not auth_header.startswith('Bearer '):
            return jsonify({'error': 'Authorization header must start with Bearer'}), 401

        try:
            # Extract token from Bearer header
            token = auth_header[7:]  # Remove 'Bearer ' prefix

            # Decode JWT token with matching secret key and algorithm
            payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=['HS256'])
            
            current_user = {
                'user_id': payload['user_id'],
                'username': payload['username']
            }
            
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token has expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Token is invalid'}), 401
        except KeyError as e:
            return jsonify({'error': f'Token missing required field: {str(e)}'}), 401

        return f(current_user, *args, **kwargs)

    return decorated

@conversation.route('/auth/conversation/<other_user_id>', methods=['GET'])
@token_required
def get_conversation_auth(current_user, other_user_id):
    """Get conversation between authenticated user and another user"""
    try:
        user_id = current_user['user_id']

        # Check if the other user exists
        if not check_user_exists(other_user_id):
            return jsonify({
                'error': 'User not found'
            }), 404

        # Check if user is trying to get conversation with themselves
        if user_id == other_user_id:
            return jsonify({
                'error': 'Cannot get conversation with yourself'
            }), 400

        conn = sqlite3.connect(CHAT_DATABASE)
        cursor = conn.cursor()

        # Get messages between the two users
        cursor.execute('''
            SELECT id, sender_user_id, recipient_user_id, message, timestamp, is_read
            FROM messages
            WHERE (sender_user_id = ? AND recipient_user_id = ?)
               OR (sender_user_id = ? AND recipient_user_id = ?)
            ORDER BY timestamp ASC
        ''', (user_id, other_user_id, other_user_id, user_id))

        messages = []
        for row in cursor.fetchall():
            messages.append({
                'message_id': row[0],
                'sender': row[1],
                'recipient': row[2],
                'message': row[3],
                'timestamp': row[4],
                'is_read': bool(row[5]),
                'direction': 'sent' if row[1] == user_id else 'received'
            })

        # Mark received messages as read
        cursor.execute('''
            UPDATE messages 
            SET is_read = 1 
            WHERE sender_user_id = ? AND recipient_user_id = ? AND is_read = 0
        ''', (other_user_id, user_id))

        conn.commit()
        conn.close()

        return jsonify({
            'conversation': messages,
            'participants': [user_id, other_user_id],
            'total_messages': len(messages),
            'current_user': user_id,
            'other_user': other_user_id
        }), 200

    except Exception as e:
        return jsonify({
            'error': f'Failed to fetch conversation: {str(e)}'
        }), 500

@conversation.route('/auth/conversations', methods=['GET'])
@token_required
def get_all_conversations(current_user):
    """Get all conversations for the authenticated user"""
    try:
        user_id = current_user['user_id']

        conn = sqlite3.connect(CHAT_DATABASE)
        cursor = conn.cursor()

        # Get all unique conversations for the user
        cursor.execute('''
            SELECT 
                CASE 
                    WHEN sender_user_id = ? THEN recipient_user_id 
                    ELSE sender_user_id 
                END as other_user_id,
                MAX(timestamp) as last_message_time,
                COUNT(*) as message_count,
                SUM(CASE WHEN recipient_user_id = ? AND is_read = 0 THEN 1 ELSE 0 END) as unread_count
            FROM messages
            WHERE sender_user_id = ? OR recipient_user_id = ?
            GROUP BY other_user_id
            ORDER BY last_message_time DESC
        ''', (user_id, user_id, user_id, user_id))

        conversations = []
        for row in cursor.fetchall():
            # Get the last message
            cursor.execute('''
                SELECT message, sender_user_id, timestamp
                FROM messages
                WHERE (sender_user_id = ? AND recipient_user_id = ?)
                   OR (sender_user_id = ? AND recipient_user_id = ?)
                ORDER BY timestamp DESC
                LIMIT 1
            ''', (user_id, row[0], row[0], user_id))
            
            last_message = cursor.fetchone()
            
            conversations.append({
                'other_user_id': row[0],
                'last_message_time': row[1],
                'message_count': row[2],
                'unread_count': row[3],
                'last_message': {
                    'content': last_message[0] if last_message else None,
                    'sender': last_message[1] if last_message else None,
                    'timestamp': last_message[2] if last_message else None,
                    'direction': 'sent' if last_message and last_message[1] == user_id else 'received'
                } if last_message else None
            })

        conn.close()

        return jsonify({
            'conversations': conversations,
            'total_conversations': len(conversations),
            'user_id': user_id
        }), 200

    except Exception as e:
        return jsonify({
            'error': f'Failed to fetch conversations: {str(e)}'
        }), 500
