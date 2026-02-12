from flask import Flask, request

app = Flask(__name__)

@app.route('/')
def index():
    # Get client IP from X-Forwarded-For header (CloudFront -> ALB -> ECS)
    # The first value in X-Forwarded-For is the original client IP
    x_forwarded_for = request.headers.get('X-Forwarded-For')
    
    if x_forwarded_for:
        # Take the first IP in the comma-separated list
        client_ip = x_forwarded_for.split(',')[0].strip()
    else:
        # Fallback to remote_addr if header doesn't exist
        client_ip = request.remote_addr
    
    # Return simple HTML page with the IP
    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Client IP Display</title>
        <style>
            body {{
                font-family: Arial, sans-serif;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                margin: 0;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            }}
            .container {{
                background: white;
                padding: 40px;
                border-radius: 10px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.2);
                text-align: center;
            }}
            h1 {{
                color: #333;
                margin: 0;
            }}
            .ip {{
                color: #667eea;
                font-weight: bold;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Your IP is: <span class="ip">{client_ip}</span></h1>
        </div>
    </body>
    </html>
    """
    return html

if __name__ == '__main__':
    # For local testing only - gunicorn will be used in production
    app.run(host='0.0.0.0', port=8080, debug=True)
