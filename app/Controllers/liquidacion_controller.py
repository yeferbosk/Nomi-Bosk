from flask import Blueprint, render_template, request, redirect, url_for
from app import get_connection
from app.Controllers import empleado_controller

# Inicialización del Blueprint
liquidacion_bp = Blueprint('liquidacion_bp', __name__)

# Ruta para ver la lista de liquidaciones
@liquidacion_bp.route('/liquidacion')
def lista_liquidaciones():
    liquidaciones = obtener_liquidaciones()
    return render_template('liquidacion/listado_liquidaciones.html', liquidaciones=liquidaciones)

# Ruta para crear una liquidación
@liquidacion_bp.route('/liquidacion/crear', methods=['GET', 'POST'])
def crear_liquidacion():
    if request.method == 'POST':
        data = {
            'id_empleado': request.form['id_empleado'],
            'tipo_pago': request.form['tipo_pago'],
            'fecha_pago': request.form['fecha_pago']
        }
        _crear_liquidacion_backend(data)
        return redirect(url_for('liquidacion_bp.lista_liquidaciones'))
    
    # Obtener empleados para el formulario de creación de liquidación
    empleados = empleado_controller.obtener_empleados()
    return render_template('liquidacion/crear.html', empleados=empleados)

# Ruta para crear liquidación masiva
@liquidacion_bp.route('/crear_masiva', methods=['POST'])
def crear_liquidacion_masiva():
    tipo_pago = request.form['tipo_pago']
    conn = get_connection()
    cursor = conn.cursor()
    # Llamar al procedimiento para crear liquidaciones masivas
    cursor.callproc('crear_liquidaciones_masivas', [tipo_pago])
    conn.commit()
    cursor.close()
    conn.close()
    return redirect(url_for('liquidacion_bp.lista_liquidaciones'))


# Función para crear una liquidación (backend)
def _crear_liquidacion_backend(data):
    """Implementa la lógica para crear una liquidación individual en la base de datos."""
    conn = get_connection()
    cursor = conn.cursor()
    # Llamamos al procedimiento almacenado para crear la liquidación
    cursor.callproc('crear_liquidacion_nomina', [
        data['id_empleado'],
        data['tipo_pago']
    ])
    conn.commit()
    cursor.close()
    conn.close()

# Función para obtener todas las liquidaciones
def obtener_liquidaciones():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
    SELECT 
        l.id_liquidacion,
        e.nombre,
        e.n_documento,
        e.cargo,
        l.tipo_pago,
        DATE_FORMAT(l.fecha_pago, '%Y-%m-%d') as fecha_pago,
        c.salario_bruto as salario_base,
        h.cantidad as horas_extra,
        l.prima_servicios,
        ss.salud as salud,
        ss.pension as pension,
        l.total_devengado, 
        l.total_deducciones,
        l.auxilio_transporte,           
        l.total_pago           
    FROM Liquidacion l
    JOIN Empleado e ON l.id_empleado = e.id_empleado
    JOIN Contrato c ON c.id_empleado = e.id_empleado 
    LEFT JOIN Horas_Extra h ON h.id_empleado = e.id_empleado
    LEFT JOIN Seguridad_Social ss ON ss.id_empleado = e.id_empleado
    ORDER BY l.fecha_pago DESC
    """)
    liquidaciones = cursor.fetchall()
    cursor.close()
    conn.close()
    return liquidaciones
