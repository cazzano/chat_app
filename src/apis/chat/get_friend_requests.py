from flask import Flask, request, jsonify, Blueprint
import sqlite3
import jwt
from functools import wraps
from datetime import datetime
import json

# Configuration - consistent with other files
DATABASE = 'users.db'  # Main users database
FR_REQUESTS_DATABASE = 'fr_requests.db'
JWT_SECRET_KEY = 'your-secret-key-change-this-in-production'

get_requests = Blueprint('get_requests', __name__)

def get_db():
    """Get database connection"""
    db = sqlite3.connect(DATABASE)
    db.row_factory = sqlite3.Row
    return db

def get_fr_db():
    """Get friend requests database connection"""
    db = sqlite3.connect(FR_REQUESTS_DATABASE)
    db.row_factory = sqlite3.Row
    return db

def token_required(f):
    """
    Decorator to verify JWT token
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
    """Initialize the friend requests database if it doesn't exist"""
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
    except Exception as e:
        print(f"Error initializing friend requests database: {e}")

@get_requests.route('/get_requests', methods=['GET'])
@token_required
def get_friend_requests(current_user):
    """
    Get all friend requests sent by OTHER USERS to the current authenticated user
    Headers: 
        Authorization: Bearer <your_jwt_token>
    Query Parameters:
        status: optional - filter by status ('pending', 'accepted', 'rejected')
        limit: optional - limit number of results (default: 50)
        offset: optional - offset for pagination (default: 0)
    """
    try:
        # Initialize database if it doesn't exist
        init_friend_requests_db()
        
        # Get query parameters
        status_filter = request.args.get('status', '').strip().lower()
        limit = request.args.get('limit', 50, type=int)
        offset = request.args.get('offset', 0, type=int)
        
        # Validate limit and offset
        if limit > 100:
            limit = 100  # Cap at 100 for performance
        if offset < 0:
            offset = 0
            
        # Build SQL query
        base_query = '''
            SELECT request_id, sender_user_id, sender_username, status, request_data, timestamp
            FROM friend_requests
            WHERE recipient_user_id = ?
        '''
        
        params = [current_user['user_id']]
        
        # Add status filter if provided
        if status_filter and status_filter in ['pending', 'accepted', 'rejected']:
            base_query += ' AND status = ?'
            params.append(status_filter)
            
        # Add ordering, limit and offset
        base_query += ' ORDER BY timestamp DESC LIMIT ? OFFSET ?'
        params.extend([limit, offset])
        
        with get_fr_db() as conn:
            cursor = conn.execute(base_query, params)
            
            requests = []
            for row in cursor.fetchall():
                try:
                    # Try to parse JSON request_data
                    request_data = json.loads(row['request_data'])
                except (json.JSONDecodeError, TypeError):
                    # If parsing fails, use raw data
                    request_data = row['request_data']
                
                requests.append({
                    'request_id': row['request_id'],
                    'sender': {
                        'user_id': row['sender_user_id'],
                        'username': row['sender_username']
                    },
                    'status': row['status'],
                    'request_data': request_data,
                    'timestamp': row['timestamp']
                })

            # Get total count for pagination info
            count_query = '''
                SELECT COUNT(*) as total
                FROM friend_requests
                WHERE recipient_user_id = ?
            '''
            count_params = [current_user['user_id']]
            
            if status_filter and status_filter in ['pending', 'accepted', 'rejected']:
                count_query += ' AND status = ?'
                count_params.append(status_filter)
                
            cursor = conn.execute(count_query, count_params)
            total_count = cursor.fetchone()['total']

        return jsonify({
            'message': 'Friend requests retrieved successfully',
            'recipient': {
                'user_id': current_user['user_id'],
                'username': current_user['username']
            },
            'requests': requests,
            'pagination': {
                'count': len(requests),
                'total_count': total_count,
                'limit': limit,
                'offset': offset,
                'has_more': (offset + len(requests)) < total_count
            },
            'filters': {
                'status': status_filter if status_filter else 'all'
            },
            'timestamp': datetime.now().isoformat()
        }), 200

    except Exception as e:
        print(f"Get friend requests error: {e}")
        return jsonify({
            'error': f'Failed to retrieve friend requests: {str(e)}'
        }), 500

@get_requests.route('/get_requests/pending', methods=['GET'])
@token_required
def get_pending_requests(current_user):
    """
    Get only PENDING friend requests sent by other users to the current authenticated user
    Headers: 
        Authorization: Bearer <your_jwt_token>
    """
    try:
        init_friend_requests_db()
        
        with get_fr_db() as conn:
            cursor = conn.execute('''
                SELECT request_id, sender_user_id, sender_username, status, request_data, timestamp
                FROM friend_requests
                WHERE recipient_user_id = ? AND status = 'pending'
                ORDER BY timestamp DESC
            ''', (current_user['user_id'],))
            
            requests = []
            for row in cursor.fetchall():
                try:
                    request_data = json.loads(row['request_data'])
                except (json.JSONDecodeError, TypeError):
                    request_data = row['request_data']
                
                requests.append({
                    'request_id': row['request_id'],
                    'sender': {
                        'user_id': row['sender_user_id'],
                        'username': row['sender_username']
                    },
                    'status': row['status'],
                    'request_data': request_data,
                    'timestamp': row['timestamp']
                })

        return jsonify({
            'message': 'Pending friend requests retrieved successfully',
            'recipient': {
                'user_id': current_user['user_id'],
                'username': current_user['username']
            },
            'pending_requests': requests,
            'count': len(requests),
            'timestamp': datetime.now().isoformat()
        }), 200

    except Exception as e:
        print(f"Get pending requests error: {e}")
        return jsonify({
            'error': f'Failed to retrieve pending requests: {str(e)}'
        }), 500

@get_requests.route('/get_requests/<int:request_id>', methods=['GET'])
@token_required
def get_specific_request(current_user, request_id):
    """
    Get details of a specific friend request by ID (only if the current user is the recipient)
    Headers: 
        Authorization: Bearer <your_jwt_token>
    URL Parameters:
        request_id: The ID of the friend request to retrieve
    """
    try:
        init_friend_requests_db()
        
        with get_fr_db() as conn:
            cursor = conn.execute('''
                SELECT request_id, sender_user_id, sender_username, recipient_user_id, 
                       recipient_username, status, request_data, timestamp
                FROM friend_requests
                WHERE request_id = ? AND recipient_user_id = ?
            ''', (request_id, current_user['user_id']))
            
            row = cursor.fetchone()
            
            if not row:
                return jsonify({
                    'error': 'Friend request not found or you are not the recipient',
                    'request_id': request_id
                }), 404
            
            try:
                request_data = json.loads(row['request_data'])
            except (json.JSONDecodeError, TypeError):
                request_data = row['request_data']
            
            friend_request = {
                'request_id': row['request_id'],
                'sender': {
                    'user_id': row['sender_user_id'],
                    'username': row['sender_username']
                },
                'recipient': {
                    'user_id': row['recipient_user_id'],
                    'username': row['recipient_username']
                },
                'status': row['status'],
                'request_data': request_data,
                'timestamp': row['timestamp']
            }

        return jsonify({
            'message': 'Friend request details retrieved successfully',
            'request': friend_request,
            'timestamp': datetime.now().isoformat()
        }), 200

    except Exception as e:
        print(f"Get specific request error: {e}")
        return jsonify({
            'error': f'Failed to retrieve request details: {str(e)}'
        }), 500

@get_requests.route('/get_requests/stats', methods=['GET'])
@token_required
def get_request_stats(current_user):
    """
    Get statistics about friend requests for the current user
    Headers: 
        Authorization: Bearer <your_jwt_token>
    """
    try:
        init_friend_requests_db()
        
        with get_fr_db() as conn:
            # Get counts by status for received requests
            cursor = conn.execute('''
                SELECT status, COUNT(*) as count
                FROM friend_requests
                WHERE recipient_user_id = ?
                GROUP BY status
            ''', (current_user['user_id'],))
            
            received_stats = {}
            for row in cursor.fetchall():
                received_stats[row['status']] = row['count']
            
            # Get counts by status for sent requests
            cursor = conn.execute('''
                SELECT status, COUNT(*) as count
                FROM friend_requests
                WHERE sender_user_id = ?
                GROUP BY status
            ''', (current_user['user_id'],))
            
            sent_stats = {}
            for row in cursor.fetchall():
                sent_stats[row['status']] = row['count']

        return jsonify({
            'message': 'Friend request statistics retrieved successfully',
            'user': {
                'user_id': current_user['user_id'],
                'username': current_user['username']
            },
            'received_requests': {
                'pending': received_stats.get('pending', 0),
                'accepted': received_stats.get('accepted', 0),
                'rejected': received_stats.get('rejected', 0),
                'total': sum(received_stats.values())
            },
            'sent_requests': {
                'pending': sent_stats.get('pending', 0),
                'accepted': sent_stats.get('accepted', 0),
                'rejected': sent_stats.get('rejected', 0),
                'total': sum(sent_stats.values())
            },
            'timestamp': datetime.now().isoformat()
        }), 200

    except Exception as e:
        print(f"Get request stats error: {e}")
        return jsonify({
            'error': f'Failed to retrieve request statistics: {str(e)}'
        }), 500
