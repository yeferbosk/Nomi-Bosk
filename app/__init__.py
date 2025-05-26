import mysql.connector
from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

db = SQLAlchemy()

from app.Models.Bonos import Bonos
from app.Models.Cesantias import Cesantias
from app.Models.Contrato import Contrato
# Import models
from app.Models.Empleado import Empleado
from app.Models.Incapacidad import Incapacidad
from app.Models.Liquidacion import Liquidacion
from app.Models.Seguridad__social import SeguridadSocial
from app.Models.TiposBonos import TiposBonos
from app.Models.Vacaciones import Vacaciones


def create_app():
    # Crear la instancia de la aplicación Flask
    app = Flask(__name__)
    CORS(app)

    app.secret_key = '123'
    # Configuración de la base de datos
    app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:12345678@localhost/Nomina_ProyectoFinalBD'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    # Inicializar la base de datos con la aplicación
    db.init_app(app)

    # Ruta principal
    @app.route('/')
    def home():
        return render_template('dashboard.html')

    # 👇 Importar los controladores dentro de la función create_app
    from app.Controllers import \
        liquidacion_controller  # Importa el controlador de liquidación
    from app.Controllers import (cesantias_controller,
                                 liquidacion_vacaciones_controller,
                                 seguridadSocial_controller)
    from app.Controllers.dashboard_controller import dashboard_bp
    from app.Controllers.deducciones_controller import deducciones_bp
    from app.Controllers.empleado_controller import empleado_bp  # Importa el Blueprint directamente
    from app.Controllers.vacaciones_controller import vacaciones_bp
    from app.Controllers.contrato_controller import contrato_bp  # Importa el controlador de contrato
    from app.routes.horas_extra_routes import horas_extra_bp  # Importar el nuevo blueprint de horas extras

    # Registrar los blueprints con el prefijo de URL adecuado
    print("\n=== Registrando Blueprints ===")
    
    print("🧩 Registrando blueprint para Horas Extras...")
    app.register_blueprint(horas_extra_bp, url_prefix='/api/horas_extras')
    
    print("🧩 Registrando blueprint para empleados...")
    app.register_blueprint(empleado_bp)  # Ya tiene su propio url_prefix
    print("🧩 Registrando blueprint para liquidaciones...")
    app.register_blueprint(liquidacion_controller.liquidacion_bp, url_prefix='/api')
    print("🧩 Registrando blueprint para Cesantias...")
    app.register_blueprint(cesantias_controller.cesantias_bp, url_prefix='/api')
    print("🧩 Registrando blueprint para Seguridad Social...")
    app.register_blueprint(seguridadSocial_controller.seguridad_social_bp, url_prefix='/api')
    print("🧩 Registrando blueprint para Liquidaciones de Vacaciones...")
    app.register_blueprint(liquidacion_vacaciones_controller.liquidacion_vacaciones, url_prefix='/api')
    print("🧩 Registrando blueprint para Vacaciones...")
    app.register_blueprint(vacaciones_bp)
    print("🧩 Registrando blueprint para Deducciones...")
    app.register_blueprint(deducciones_bp)
    print("🧩 Registrando blueprint para Dashboard...")
    app.register_blueprint(dashboard_bp)
    print("🧩 Registrando blueprint para Contratos...")
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
        password="12345678",
        database="Nomina_ProyectoFinalBD"
    )
