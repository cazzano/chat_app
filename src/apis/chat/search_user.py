from flask import Flask, request, jsonify, Blueprint
import sqlite3
import jwt
from functools import wraps
from datetime import datetime

# Configuration
DATABASE = 'users.db'  # Same database as login_jwt.py
JWT_SECRET_KEY = 'your-secret-key-change-this-in-production'  # Should match login_jwt.py

search_user = Blueprint('search_user', __name__)

def get_db():
    """Get database connection (same as login_jwt.py)"""
    db = sqlite3.connect(DATABASE)
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

def search_user_by_username(username):
    """Search for a user by username in the users database"""
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
        print(f"Error searching user by username: {e}")
        return None

def search_user_by_id(user_id):
    """Search for a user by user_id in the users database"""
    try:
        with get_db() as conn:
            cursor = conn.execute('''
                SELECT user_id, username 
                FROM users 
                WHERE user_id = ?
            ''', (user_id,))
            user = cursor.fetchone()
            
            if user:
                return {
                    'user_id': user['user_id'],
                    'username': user['username']
                }
            return None
            
    except Exception as e:
        print(f"Error searching user by ID: {e}")
        return None

@search_user.route('/search_user', methods=['GET'])
@token_required
def search_user_by_username_endpoint(current_user):
    """
    Search for a user by username using JWT Bearer token authentication
    Headers: 
        Authorization: Bearer <your_jwt_token>
        username: <username_to_search>
    """
    try:
        # Get username from header
        username = request.headers.get('username')
        
        if not username:
            return jsonify({
                'error': 'Username is required in header',
                'usage': 'Add header: username: <username_to_search>'
            }), 400

        # Search for the user in the database
        user_data = search_user_by_username(username)
        
        if not user_data:
            return jsonify({
                'error': 'User not found',
                'searched_username': username
            }), 404

        return jsonify({
            'message': 'User found successfully',
            'user_data': {
                'user_id': user_data['user_id'],
                'username': user_data['username']
            },
            'searched_by': {
                'user_id': current_user['user_id'],
                'username': current_user['username']
            },
            'timestamp': datetime.now().isoformat()
        }), 200

    except Exception as e:
        print(f"Search user error: {e}")
        return jsonify({
            'error': f'Failed to search user: {str(e)}'
        }), 500

@search_user.route('/search_user_by_id', methods=['GET'])
@token_required
def search_user_by_id_endpoint(current_user):
    """
    Search for a user by user_id using JWT Bearer token authentication
    Headers: 
        Authorization: Bearer <your_jwt_token>
        user_id: <user_id_to_search>
    """
    try:
        # Get user_id from header
        search_user_id = request.headers.get('user_id')
        
        if not search_user_id:
            return jsonify({
                'error': 'user_id is required in header',
                'usage': 'Add header: user_id: <user_id_to_search>'
            }), 400

        # Search for the user in the database
        user_data = search_user_by_id(search_user_id)

        if not user_data:
            return jsonify({
                'error': 'User not found',
                'searched_user_id': search_user_id
            }), 404

        return jsonify({
            'message': 'User found successfully',
            'user_data': {
                'user_id': user_data['user_id'],
                'username': user_data['username']
            },
            'searched_by': {
                'user_id': current_user['user_id'],
                'username': current_user['username']
            },
            'timestamp': datetime.now().isoformat()
        }), 200

    except Exception as e:
        print(f"Search user by ID error: {e}")
        return jsonify({
            'error': f'Failed to search user: {str(e)}'
        }), 500

@search_user.route('/search_user_query', methods=['GET'])
@token_required
def search_user_by_query_parameter(current_user):
    """
    Search for a user by username using query parameters and JWT Bearer token authentication
    Headers: 
        Authorization: Bearer <your_jwt_token>
    Query Parameters:
        ?username=<username_to_search>
    """
    try:
        # Get username from query parameter
        username = request.args.get('username')
        
        if not username:
            return jsonify({
                'error': 'Username is required as query parameter',
                'usage': 'Add query parameter: ?username=<username_to_search>'
            }), 400

        # Search for the user in the database
        user_data = search_user_by_username(username)
        
        if not user_data:
            return jsonify({
                'error': 'User not found',
                'searched_username': username
            }), 404

        return jsonify({
            'message': 'User found successfully',
            'user_data': {
                'user_id': user_data['user_id'],
                'username': user_data['username']
            },
            'searched_by': {
                'user_id': current_user['user_id'],
                'username': current_user['username']
            },
            'timestamp': datetime.now().isoformat()
        }), 200

    except Exception as e:
        print(f"Search user by query error: {e}")
        return jsonify({
            'error': f'Failed to search user: {str(e)}'
        }), 500

# Optional: Endpoint to get current user info from token
@search_user.route('/me', methods=['GET'])
@token_required
def get_current_user(current_user):
    """
    Get current user information from JWT token
    Headers: 
        Authorization: Bearer <your_jwt_token>
    """
    try:
        return jsonify({
            'message': 'Current user information',
            'user_data': {
                'user_id': current_user['user_id'],
                'username': current_user['username']
            },
            'token_expires_at': datetime.fromtimestamp(current_user['exp']).isoformat(),
            'timestamp': datetime.now().isoformat()
        }), 200

    except Exception as e:
        print(f"Get current user error: {e}")
        return jsonify({
            'error': f'Failed to get current user: {str(e)}'
        }), 500
