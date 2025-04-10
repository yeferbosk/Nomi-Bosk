from app.Models.Empleado import Empleado
from app import get_connection

def crear_empleado(data):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.callproc('crear_empleado', [
        data['nombre'],
        data['email'],
        data['fecha_nacimiento'],
        data['telefono'],
        data['estado_civil'],
        data['genero'],
        data['n_documento'],
        data['cargo'],
        data['estado'],
        data['direccion'],
        data['fecha_ingreso']
    ])
    conn.commit()
    cursor.close()
    conn.close()


def obtener_empleados():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.callproc('obtener_empleados')
    for result in cursor.stored_results():
        empleados = result.fetchall()
    cursor.close()
    conn.close()
    return empleados
