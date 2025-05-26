from flask import Blueprint, render_template, request
from app.Controllers.horas_extra_controller import HorasExtraController

horas_extra_bp = Blueprint('horas_extra', __name__)
controller = HorasExtraController()

@horas_extra_bp.before_request
def before_request():
    print("\n=== Nueva solicitud a horas_extra_bp ===")
    print(f"Método: {request.method}")
    print(f"URL: {request.url}")
    print(f"Datos: {request.get_json(silent=True)}")

# Ruta para la vista
@horas_extra_bp.route('/vista')
def vista_horas_extra():
    print("\n=== Renderizando vista de horas extras ===")
    return render_template('horas_extras.html')

# Rutas de la API
@horas_extra_bp.route('/', methods=['GET'])
def obtener_horas_extra():
    print("\n=== Procesando GET /api/horas_extras/ ===")
    return controller.obtener_horas_extra()

@horas_extra_bp.route('/', methods=['POST'])
def crear_horas_extra():
    print("\n=== Procesando POST /api/horas_extras/ ===")
    return controller.crear_horas_extra()

@horas_extra_bp.route('/<id>', methods=['PUT'])
def actualizar_horas_extra(id):
    print(f"\n=== Procesando PUT /api/horas_extras/{id} ===")
    return controller.actualizar_horas_extra(id)

@horas_extra_bp.route('/<id>', methods=['DELETE'])
def eliminar_horas_extra(id):
    print(f"\n=== Procesando DELETE /api/horas_extras/{id} ===")
    return controller.eliminar_horas_extra(id) 