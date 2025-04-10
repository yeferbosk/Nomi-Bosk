from flask import Flask
from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy


db = SQLAlchemy()

def create_app():
    app = Flask(__name__)

    app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:12345678@localhost/Nomina_ProyectoFinalBD2'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    db.init_app(app)

  
    @app.route('/')
    def home():
        return render_template('dashboard.html')


    # 👇 Importar blueprint y registrar
    from app.Routes import empleado_routes
    print("🧩 Blueprint definido con url_prefix:", empleado_routes.empleado_bp.url_prefix)

    app.register_blueprint(empleado_routes.empleado_bp, url_prefix='/api')

    # 👇 Mostrar todas las rutas registradas
    print("\n🔍 Rutas disponibles:")
    for rule in app.url_map.iter_rules():
        print(rule)

    return app


import mysql.connector

def get_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="12345678",
        database="Nomina_ProyectoFinalBD2"
    )
