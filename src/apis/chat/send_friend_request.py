from flask import Flask, request, jsonify, Blueprint
import sqlite3
import jwt
from functools import wraps
from datetime import datetime
import json

# Configuration - consistent with login_jwt.py
DATABASE = 'users.db'  # Main users database
FR_REQUESTS_DATABASE = 'fr_requests.db'
FRIENDS_DATABASE = 'friends.db'
JWT_SECRET_KEY = 'your-secret-key-change-this-in-production'  # Should match login_jwt.py

send_friend_request = Blueprint('send_friend_request', __name__)

def get_db():
    """Get database connection (same as login_jwt.py)"""
    db = sqlite3.connect(DATABASE)
    db.row_factory = sqlite3.Row
    return db

def get_fr_db():
    """Get friend requests database connection"""
    db = sqlite3.connect(FR_REQUESTS_DATABASE)
    db.row_factory = sqlite3.Row
    return db

def get_friends_db():
    """Get friends database connection"""
    db = sqlite3.connect(FRIENDS_DATABASE)
    db.row_factory = sqlite3.Row
    return db

def token_required(f):
    """
    Decorator to verify JWT token - matches the pattern from login_jwt.py verify_token endpoint
    """
    @wraps(f)
    def decorated(*args, **kwargs):
        try:
            auth_header = request.headers.get('Authorization')
            
            if not auth_header:
                return jsonify({'error': 'Authorization header is missing'}), 401
                
            if not auth_header.startswith('Bearer '):
                return jsonify({'error': 'Authorization header must start with Bearer'}), 401
                
            token = auth_header[7:]  # Remove 'Bearer ' prefix
            
            try:
                payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=['HS256'])
                current_user = {
                    'user_id': payload.get('user_id'),
                    'username': payload.get('username'),
                    'exp': payload.get('exp')
                }
            except jwt.ExpiredSignatureError:
                return jsonify({'error': 'Token has expired'}), 401
            except jwt.InvalidTokenError:
                return jsonify({'error': 'Token is invalid'}), 401
                
        except Exception as e:
            return jsonify({'error': 'An error occurred during token verification'}), 500

        return f(current_user, *args, **kwargs)
    return decorated

def init_friend_requests_db():
    """Initialize the friend requests database"""
    try:
        with get_fr_db() as conn:
            cursor = conn.execute('''
                CREATE TABLE IF NOT EXISTS friend_requests (
                    request_id INTEGER PRIMARY KEY AUTOINCREMENT,
                    sender_user_id TEXT NOT NULL,
                    sender_username TEXT NOT NULL,
                    recipient_user_id TEXT NOT NULL,
                    recipient_username TEXT NOT NULL,
                    status TEXT DEFAULT 'pending',
                    request_data TEXT NOT NULL,
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                    UNIQUE(sender_user_id, recipient_user_id)
                )
            ''')
            conn.commit()
        print("Friend requests database initialized successfully")
    except Exception as e:
        print(f"Error initializing friend requests database: {e}")

def init_friends_db():
    """Initialize the friends database"""
    try:
        with get_friends_db() as conn:
            cursor = conn.execute('''
                CREATE TABLE IF NOT EXISTS friends (
                    friendship_id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user1_id TEXT NOT NULL,
                    user1_username TEXT NOT NULL,
                    user2_id TEXT NOT NULL,
                    user2_username TEXT NOT NULL,
                    friendship_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                    UNIQUE(user1_id, user2_id)
                )
            ''')
            conn.commit()
        print("Friends database initialized successfully")
    except Exception as e:
        print(f"Error initializing friends database: {e}")

def get_user_by_username(username):
    """Get user info by username from users database"""
    try:
        with get_db() as conn:
            cursor = conn.execute('''
                SELECT user_id, username 
                FROM users 
                WHERE username = ?
            ''', (username,))
            user = cursor.fetchone()
            
            if user:
                return {
                    'user_id': user['user_id'],
                    'username': user['username']
                }
            return None
            
    except Exception as e:
        print(f"Error getting user by username: {e}")
        return None

def check_if_already_friends(user1_id, user2_id):
    """Check if two users are already friends"""
    try:
        with get_friends_db() as conn:
            cursor = conn.execute('''
                SELECT friendship_id FROM friends
                WHERE (user1_id = ? AND user2_id = ?) OR (user1_id = ? AND user2_id = ?)
            ''', (user1_id, user2_id, user2_id, user1_id))
            result = cursor.fetchone()
            return result is not None
    except Exception as e:
        print(f"Error checking if users are friends: {e}")
        return False

def check_existing_friend_request(sender_user_id, recipient_user_id):
    """Check if a friend request already exists between two users"""
    try:
        with get_fr_db() as conn:
            cursor = conn.execute('''
                SELECT request_id, status FROM friend_requests
                WHERE (sender_user_id = ? AND recipient_user_id = ?)
                   OR (sender_user_id = ? AND recipient_user_id = ?)
            ''', (sender_user_id, recipient_user_id, recipient_user_id, sender_user_id))
            result = cursor.fetchone()
            
            if result:
                return {
                    'request_id': result['request_id'],
                    'status': result['status']
                }
            return None
    except Exception as e:
        print(f"Error checking existing friend request: {e}")
        return None

@send_friend_request.route('/send_friend_request', methods=['POST'])
@token_required
def send_friend_request_endpoint(current_user):
    """
    Send a friend request using JWT Bearer token authentication
    Headers: 
        Authorization: Bearer <your_jwt_token>
        Content-Type: application/json
    Body:
        {
            "username": "target_username"
        }
    """
    try:
        # Initialize databases if they don't exist
        init_friend_requests_db()
        init_friends_db()
        
        data = request.get_json()
        if not data:
            return jsonify({
                'error': 'Request body is required',
                'usage': 'Send JSON: {"username": "target_username"}'
            }), 400

        if 'username' not in data:
            return jsonify({
                'error': 'Username is required',
                'usage': 'Send JSON: {"username": "target_username"}'
            }), 400

        target_username = data['username'].strip()
        sender_user_id = current_user['user_id']
        sender_username = current_user['username']

        if not target_username:
            return jsonify({
                'error': 'Username cannot be empty'
            }), 400

        # Get recipient's user info by username
        recipient_info = get_user_by_username(target_username)
        if not recipient_info:
            return jsonify({
                'error': 'Username not found',
                'searched_username': target_username
            }), 404

        recipient_user_id = recipient_info['user_id']
        recipient_username = recipient_info['username']

        # Check if sender is trying to send friend request to themselves
        if sender_user_id == recipient_user_id:
            return jsonify({
                'error': 'Cannot send friend request to yourself'
            }), 400

        # Check if they are already friends
        if check_if_already_friends(sender_user_id, recipient_user_id):
            return jsonify({
                'error': f'You are already friends with {recipient_username}'
            }), 409

        # Check if friend request already exists
        existing_request = check_existing_friend_request(sender_user_id, recipient_user_id)
        if existing_request:
            if existing_request['status'] == 'pending':
                return jsonify({
                    'error': 'Friend request already pending between these users',
                    'existing_request_id': existing_request['request_id']
                }), 409
            elif existing_request['status'] == 'rejected':
                return jsonify({
                    'error': 'Previous friend request was rejected. Wait before sending another.',
                    'previous_request_id': existing_request['request_id']
                }), 409

        # Create friend request data
        friend_request_data = {
            "type": "friend_request",
            "from": sender_username,
            "to": recipient_username,
            "message": f"Friend request from {sender_username}",
            "action_required": "accept_or_reject",
            "created_at": datetime.now().isoformat()
        }

        # Store friend request in database
        with get_fr_db() as conn:
            cursor = conn.execute('''
                INSERT OR REPLACE INTO friend_requests 
                (sender_user_id, sender_username, recipient_user_id, recipient_username, request_data, status)
                VALUES (?, ?, ?, ?, ?, 'pending')
            ''', (sender_user_id, sender_username, recipient_user_id, recipient_username, 
                  json.dumps(friend_request_data)))

            request_id = cursor.lastrowid
            conn.commit()

        return jsonify({
            'message': 'Friend request sent successfully!',
            'request_id': request_id,
            'sender': {
                'user_id': sender_user_id,
                'username': sender_username
            },
            'recipient': {
                'user_id': recipient_user_id,
                'username': recipient_username
            },
            'request_data': friend_request_data,
            'status': 'pending',
            'timestamp': datetime.now().isoformat()
        }), 201

    except Exception as e:
        print(f"Send friend request error: {e}")
        return jsonify({
            'error': f'Failed to send friend request: {str(e)}'
        }), 500

@send_friend_request.route('/get_sent_requests', methods=['GET'])
@token_required
def get_sent_requests(current_user):
    """
    Get all friend requests sent by the current user
    Headers: 
        Authorization: Bearer <your_jwt_token>
    """
    try:
        init_friend_requests_db()
        
        with get_fr_db() as conn:
            cursor = conn.execute('''
                SELECT request_id, recipient_username, status, request_data, timestamp
                FROM friend_requests
                WHERE sender_user_id = ?
                ORDER BY timestamp DESC
            ''', (current_user['user_id'],))
            
            requests = []
            for row in cursor.fetchall():
                try:
                    request_data = json.loads(row['request_data'])
                except:
                    request_data = row['request_data']
                
                requests.append({
                    'request_id': row['request_id'],
                    'recipient_username': row['recipient_username'],
                    'status': row['status'],
                    'request_data': request_data,
                    'timestamp': row['timestamp']
                })

        return jsonify({
            'message': 'Sent friend requests retrieved successfully',
            'sent_by': {
                'user_id': current_user['user_id'],
                'username': current_user['username']
            },
            'requests': requests,
            'count': len(requests),
            'timestamp': datetime.now().isoformat()
        }), 200

    except Exception as e:
        print(f"Get sent requests error: {e}")
        return jsonify({
            'error': f'Failed to retrieve sent requests: {str(e)}'
        }), 500

@send_friend_request.route('/get_received_requests', methods=['GET'])
@token_required
def get_received_requests(current_user):
    """
    Get all friend requests received by the current user
    Headers: 
        Authorization: Bearer <your_jwt_token>
    """
    try:
        init_friend_requests_db()
        
        with get_fr_db() as conn:
            cursor = conn.execute('''
                SELECT request_id, sender_username, status, request_data, timestamp
                FROM friend_requests
                WHERE recipient_user_id = ? AND status = 'pending'
                ORDER BY timestamp DESC
            ''', (current_user['user_id'],))
            
            requests = []
            for row in cursor.fetchall():
                try:
                    request_data = json.loads(row['request_data'])
                except:
                    request_data = row['request_data']
                
                requests.append({
                    'request_id': row['request_id'],
                    'sender_username': row['sender_username'],
                    'status': row['status'],
                    'request_data': request_data,
                    'timestamp': row['timestamp']
                })

        return jsonify({
            'message': 'Received friend requests retrieved successfully',
            'received_by': {
                'user_id': current_user['user_id'],
                'username': current_user['username']
            },
            'requests': requests,
            'count': len(requests),
            'timestamp': datetime.now().isoformat()
        }), 200

    except Exception as e:
        print(f"Get received requests error: {e}")
        return jsonify({
            'error': f'Failed to retrieve received requests: {str(e)}'
        }), 500
