from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy
import mysql.connector

db = SQLAlchemy()

def create_app():
    # Crear la instancia de la aplicación Flask
    app = Flask(__name__)

    # Configuración de la base de datos
    app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:1074129082@localhost/Nomina_ProyectoFinalBD'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    # Inicializar la base de datos con la aplicación
    db.init_app(app)

    # Ruta principal
    @app.route('/')
    def home():
        return render_template('dashboard.html')

    # 👇 Importar los controladores dentro de la función create_app
    from app.Controllers.empleado_controller import empleado_bp  # Importa el Blueprint directamente
    from app.Controllers import liquidacion_controller  # Importa el controlador de liquidación
    from app.Controllers.contrato_controller import contrato_bp  # Importa el controlador de contrato

    # Registrar los blueprints con el prefijo de URL adecuado
    print("🧩 Registrando blueprint para empleados...")
    app.register_blueprint(empleado_bp)  # Ya tiene su propio url_prefix
    print("🧩 Registrando blueprint para liquidaciones...")
    app.register_blueprint(liquidacion_controller.liquidacion_bp, url_prefix='/api')
    print("🧩 Registrando blueprint para contratos...")
    app.register_blueprint(contrato_bp)  # Ya tiene su propio url_prefix

    # Mostrar las rutas disponibles para verificar que todo esté registrado correctamente
    print("\n🔍 Rutas disponibles:")
    for rule in app.url_map.iter_rules():
        print(rule)

    # Retornar la aplicación configurada
    return app

# Conexión a la base de datos
def get_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="1074129082",
        database="Nomina_ProyectoFinalBD"
    )
