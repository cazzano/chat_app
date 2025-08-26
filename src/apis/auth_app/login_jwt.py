from flask import Flask, request, jsonify, Blueprint
import sqlite3
import jwt
import pyotp
import hashlib
from functools import wraps
from datetime import datetime, timedelta

# Configuration
DATABASE = 'users.db'
JWT_SECRET_KEY = 'your-secret-key-change-this-in-production'  # Should match your auth configuration

login_jwt = Blueprint('login_jwt', __name__)

def get_db():
    """Get database connection"""
    db = sqlite3.connect(DATABASE)
    db.row_factory = sqlite3.Row
    return db

def hash_password(password):
    """Hash password using SHA256 (matching your signup.py)"""
    return hashlib.sha256(password.encode()).hexdigest()

def verify_user_credentials_with_totp(username, password, totp_code):
    """
    Verify user credentials including username, password, and TOTP code
    Returns: (user_id, is_valid, error_message)
    """
    try:
        with get_db() as conn:
            cursor = conn.execute('''
                SELECT user_id, username, password, secret_key 
                FROM users 
                WHERE username = ?
            ''', (username,))
            user = cursor.fetchone()
            
            if not user:
                return None, False, "Invalid username or password"
            
            # Verify password
            hashed_password = hash_password(password)
            if user['password'] != hashed_password:
                return None, False, "Invalid username or password"
            
            # Verify TOTP code
            secret_key = user['secret_key']
            totp = pyotp.TOTP(secret_key)
            
            # Verify the TOTP code (30 second window - no tolerance for strict timing)
            is_totp_valid = totp.verify(totp_code, valid_window=0)
            
            if not is_totp_valid:
                return None, False, "Invalid or expired TOTP code"
            
            return user['user_id'], True, None
            
    except Exception as e:
        print(f"Error verifying credentials: {e}")
        return None, False, f"An error occurred during authentication: {str(e)}"

@login_jwt.route('/login', methods=['POST'])
def login():
    """
    Login endpoint to authenticate user with username, password, and TOTP code
    Request body should contain:
    {
        "username": "your_username",
        "password": "your_password", 
        "code": "123456"  // 6-digit TOTP code from Google Authenticator
    }
    """
    try:
        data = request.get_json()

        # Validate request data
        if not data:
            return jsonify({'error': 'Request body is required'}), 400
            
        username = data.get('username')
        password = data.get('password')
        totp_code = data.get('code')

        # Check for required fields
        missing_fields = []
        if not username:
            missing_fields.append('username')
        if not password:
            missing_fields.append('password')
        if not totp_code:
            missing_fields.append('code')
            
        if missing_fields:
            return jsonify({
                'error': 'Missing required fields',
                'missing_fields': missing_fields,
                'required_fields': ['username', 'password', 'code']
            }), 400

        # Validate TOTP code format (should be 6 digits)
        if not str(totp_code).isdigit() or len(str(totp_code)) != 6:
            return jsonify({'error': 'TOTP code must be exactly 6 digits'}), 400

        # Verify credentials with TOTP
        user_id, is_valid, error_message = verify_user_credentials_with_totp(
            username, password, str(totp_code)
        )
        
        if is_valid and user_id:
            # Generate JWT token
            payload = {
                'user_id': user_id,
                'username': username,
                'exp': datetime.utcnow() + timedelta(hours=24),
                'iat': datetime.utcnow(),
                'iss': 'your-app-name'  # Optional: issuer claim
            }
            
            token = jwt.encode(payload, JWT_SECRET_KEY, algorithm='HS256')

            return jsonify({
                'message': 'Login successful!',
                'token': token,
                'user_id': user_id,
                'username': username,
                'expires_in': '24 hours',
                'token_type': 'Bearer'
            }), 200
        else:
            return jsonify({'error': error_message or 'Authentication failed'}), 401

    except Exception as e:
        print(f"Login error: {e}")
        return jsonify({'error': 'An error occurred during login'}), 500

@login_jwt.route('/verify-token', methods=['POST'])
def verify_token():
    """
    Endpoint to verify if a JWT token is valid
    Headers: Authorization: Bearer <token>
    """
    try:
        auth_header = request.headers.get('Authorization')
        
        if not auth_header:
            return jsonify({'error': 'Authorization header is missing'}), 401
            
        if not auth_header.startswith('Bearer '):
            return jsonify({'error': 'Authorization header must start with Bearer'}), 401
            
        token = auth_header[7:]  # Remove 'Bearer ' prefix
        
        try:
            payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=['HS256'])
            return jsonify({
                'message': 'Token is valid',
                'user_id': payload.get('user_id'),
                'username': payload.get('username'),
                'expires_at': datetime.fromtimestamp(payload.get('exp')).isoformat()
            }), 200
            
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token has expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Token is invalid'}), 401
            
    except Exception as e:
        print(f"Token verification error: {e}")
        return jsonify({'error': 'An error occurred during token verification'}), 500

@login_jwt.route('/test-totp/<username>', methods=['GET'])
def test_totp(username):
    """
    Test endpoint to get current TOTP code for a user (for development/testing only)
    Remove this endpoint in production!
    """
    try:
        with get_db() as conn:
            cursor = conn.execute('''
                SELECT secret_key FROM users WHERE username = ?
            ''', (username,))
            user = cursor.fetchone()
            
            if not user:
                return jsonify({'error': 'User not found'}), 404
                
            secret_key = user['secret_key']
            totp = pyotp.TOTP(secret_key)
            current_code = totp.now()
            
            return jsonify({
                'username': username,
                'current_totp_code': current_code,
                'warning': 'This endpoint should be removed in production!'
            }), 200
            
    except Exception as e:
        print(f"Test TOTP error: {e}")
        return jsonify({'error': 'An error occurred'}), 500
