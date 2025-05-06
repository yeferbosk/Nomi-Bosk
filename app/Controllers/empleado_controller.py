from app.Models.Empleado import Empleado
from app import get_connection

def crear_empleado(data):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.callproc('crear_empleado', [
        data['nombre'],
        data['n_documento'],
        data['cargo']
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

def obtener_empleado(id):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.callproc('obtener_empleado', [id])
    for result in cursor.stored_results():
        empleado = result.fetchone()
    cursor.close()
    conn.close()
    return empleado

def actualizar_empleado(id, data):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.callproc('actualizar_empleado', [
        id,
        data['nombre'],
        data['n_documento'],
        data['cargo']
    ])
    conn.commit()
    cursor.close()
    conn.close()

def eliminar_empleado(id):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.callproc('eliminar_empleado', [id])
    conn.commit()
    cursor.close()
    conn.close()
