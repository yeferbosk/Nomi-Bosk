from flask import Blueprint, render_template, request, redirect, url_for, jsonify
from app import get_connection
from app.Controllers import empleado_controller

# Inicialización del Blueprint
seguridad_social_bp = Blueprint('seguridad_social_bp', __name__)

@seguridad_social_bp.route('/seguridad_social')
def vista_seguridad_social():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT 
            e.id_empleado,
            e.nombre,
            CAST(c.salario_bruto AS DECIMAL(10,2)) as salario_bruto,
            CAST(COALESCE(ss.salud, 0) AS DECIMAL(10,2)) as salud,
            CAST(COALESCE(ss.salud_empleador, 0) AS DECIMAL(10,2)) as salud_empleador,
            CAST(COALESCE(ss.pension, 0) AS DECIMAL(10,2)) as pension,
            CAST(COALESCE(ss.pension_empleador, 0) AS DECIMAL(10,2)) as pension_empleador,
            CAST(COALESCE(ss.riesgos_laborales, 0) AS DECIMAL(10,2)) as riesgos_laborales,
            CAST(COALESCE(ss.caja_compensacion, 0) AS DECIMAL(10,2)) as caja_compensacion
        FROM Empleado e
        JOIN Contrato c ON e.id_empleado = c.id_empleado
        LEFT JOIN Seguridad_Social ss ON e.id_empleado = ss.id_empleado
        WHERE e.estado = 1
        ORDER BY e.nombre
    """)
    seguridad_social = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('seguridad_social/seguridad_social.html', seguridad_social_list=seguridad_social)

@seguridad_social_bp.route('/calcular_seguridad_social', methods=['POST'])
def calcular_seguridad_social():
    id_empleado = request.form.get('id_empleado')
    if not id_empleado:
        return jsonify({'error': 'ID de empleado no proporcionado'}), 400

    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.callproc('CalcularSeguridadSocial', [id_empleado])
        conn.commit()
        return redirect(url_for('seguridad_social_bp.vista_seguridad_social'))
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@seguridad_social_bp.route('/calcular_seguridad_social_masiva', methods=['POST'])
def calcular_seguridad_social_masiva():
    conn = get_connection()
    cursor = conn.cursor()
    try:
        # Obtener todos los empleados activos
        cursor.execute("SELECT id_empleado FROM Empleado WHERE estado = 1")
        empleados = cursor.fetchall()
        
        # Calcular seguridad social para cada empleado
        for empleado in empleados:
            cursor.callproc('CalcularSeguridadSocial', [empleado[0]])
        
        conn.commit()
        return redirect(url_for('seguridad_social_bp.vista_seguridad_social'))
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()
