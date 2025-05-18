#blueprint init
from datetime import datetime

from flask import Blueprint, flash, redirect, render_template, request, url_for

from app import get_connection

liquidacion_vacaciones = Blueprint('liquidacion_vacaciones',__name__)

@liquidacion_vacaciones.route('/liquidacion_vacaciones')
def lista_liquidacion_vacaciones():
    vacaciones = obtener_vacaciones()
    return render_template('liquidacion_vacaciones/vacaciones_liquidacion.html', vacaciones=vacaciones)

@liquidacion_vacaciones.route('/liquidacion_vacaciones/vista')
def vista_hola_mundo():
    print("Fetching vacation data...")
    vacaciones = obtener_vacaciones()
    print(f"Number of records found: {len(vacaciones)}")
    if len(vacaciones) > 0:
        print("First record:", vacaciones[0])
    return render_template('liquidacion_vacaciones/vacaciones_liquidacion.html', vacaciones=vacaciones)

@liquidacion_vacaciones.route('/insertar-vacaciones', methods=['POST'])
def insertar_vacaciones():
    try:
        id_empleado = request.form['id_empleado']
        fecha_inicio = request.form['fecha_inicio']
        fecha_fin = request.form['fecha_fin']
        dias_vacaciones = request.form['dias_vacaciones']

        conn = get_connection()
        cursor = conn.cursor()

        # Insertar vacaciones
        cursor.execute("""
            INSERT INTO Vacaciones (fecha_inicio, fecha_fin, dias_vacaciones, id_empleado)
            VALUES (%s, %s, %s, %s)
        """, (fecha_inicio, fecha_fin, dias_vacaciones, id_empleado))

        # Calcular nómina vacacional
        cursor.execute("CALL CalcularNominaVacacional(%s)", (id_empleado,))

        conn.commit()
        cursor.close()
        conn.close()

        flash('Vacaciones registradas exitosamente', 'success')
        return redirect(url_for('liquidacion_vacaciones.lista_liquidacion_vacaciones'))

    except Exception as e:
        flash(f'Error al registrar vacaciones: {str(e)}', 'error')
        return redirect(url_for('empleado_bp.pt_gestion_empleado'))

def obtener_vacaciones():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        cursor.execute("""
            SELECT 
                v.id_empleado,
                e.nombre,
                c.salario_bruto as salario_base,
                v.fecha_inicio as fecha_inicio_vacaciones,
                v.fecha_fin as fecha_fin_vacaciones,
                v.dias_vacaciones,
                DATEDIFF(v.fecha_inicio, 
                    IFNULL(
                        (SELECT MAX(v2.fecha_fin) 
                         FROM Vacaciones v2 
                         WHERE v2.id_empleado = e.id_empleado 
                         AND v2.fecha_fin < v.fecha_inicio),
                        e.fecha_ingreso
                    )
                ) as dias_laborados,
                v.valor as pago_vacaciones,
                (c.salario_bruto + v.valor) as nomina_total_mes_vacacional
            FROM Vacaciones v
            JOIN Empleado e ON v.id_empleado = e.id_empleado
            JOIN Contrato c ON e.id_empleado = c.id_empleado AND c.fecha_fin IS NULL
            ORDER BY v.fecha_inicio DESC
        """)

        resultados = cursor.fetchall()
        return resultados
    except Exception as e:
        print(f"Error al obtener vacaciones: {str(e)}")
        return []
    finally:
        cursor.close()
        conn.close()