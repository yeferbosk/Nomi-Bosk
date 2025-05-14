from flask import Blueprint, render_template, request, redirect, url_for, jsonify, session
from app import get_connection
from app.Controllers import empleado_controller

# Inicialización del Blueprint
cesantias_bp = Blueprint('cesantias_bp', __name__)

@cesantias_bp.route('/cesantias')
def vista_cesantias():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT e.id_empleado, e.nombre, c.salario_bruto, ce.valor, ce.fecha_pago, ce.i_c
        FROM Cesantias ce
        JOIN Empleado e ON ce.id_empleado = e.id_empleado
        JOIN Contrato c ON e.id_empleado = c.id_empleado
    """)
    cesantias = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('cesantias/cesantias.html', cesantias_list=cesantias)

@cesantias_bp.route('/calcular_cesantias', methods=['POST'])
def calcular_cesantias():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
    SELECT e.id_empleado, e.nombre, c.salario_bruto, ce.valor, ce.fecha_pago, ce.i_c
    FROM Cesantias ce
    JOIN Empleado e ON ce.id_empleado = e.id_empleado
    JOIN Contrato c ON e.id_empleado = c.id_empleado
    WHERE ce.fecha_pago = CURDATE()
    """)
    cesantias = cursor.fetchall()
    cursor.close()
    conn.close()

    
    return redirect(url_for('cesantias_bp.vista_cesantias'))
    
    
    
    

    


