from flask import Blueprint, render_template

from app import get_connection

# Definir el Blueprint para deducciones

deducciones_bp = Blueprint('deducciones_bp', __name__)

@deducciones_bp.route('/api/deducciones/vista')
def vista_deducciones():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        # Ejecutar el procedimiento para actualizar deducciones masivas
        cursor.callproc('actualizar_deducciones_masivas')
        # Consultar la vista
        cursor.execute('SELECT * FROM vista_impuestos_deducciones')
        deducciones = cursor.fetchall()
    finally:
        cursor.close()
        conn.close()
    return render_template('deducciones.html', deducciones=deducciones) 