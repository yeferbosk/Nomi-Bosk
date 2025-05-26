# app/Controllers/contrato_controller.py

from flask import Blueprint, render_template, request, redirect, url_for, flash
import mysql.connector
from datetime import datetime

# Función de conexión local para evitar importación circular
def get_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="1074129082",
        database="nomina_proyectofinalbd2"
    )

# Crear el blueprint
contrato_bp = Blueprint('contrato', __name__, url_prefix='/inicio/gestion_contratos')

@contrato_bp.route('/')
def pt_gestion_contratos():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.callproc('obtener_contratos')
        contratos = []
        
        for result in cursor.stored_results():
            contratos = result.fetchall()

        # Formatear fechas y asegurar que los datos estén en el formato correcto
        for contrato in contratos:
            if contrato['fecha_inicio']:
                contrato['fecha_inicio'] = datetime.strptime(str(contrato['fecha_inicio']), '%Y-%m-%d')
            if contrato['fecha_fin']:
                contrato['fecha_fin'] = datetime.strptime(str(contrato['fecha_fin']), '%Y-%m-%d')
            # Asegurar que el salario sea un número
            contrato['salario_bruto'] = float(contrato['salario_bruto']) if contrato['salario_bruto'] else 0.0

        print(f'Contratos obtenidos: {contratos}')
        return render_template('contratos/GestionContrato.html', contratos=contratos)
    except Exception as e:
        print(f'Error al obtener contratos: {str(e)}')
        return render_template('contratos/GestionContrato.html', contratos=[], error="Error al cargar los contratos")
    finally:
        cursor.close()
        conn.close()

@contrato_bp.route('/eliminar/<int:id>', methods=['POST'])
def pt_eliminar_contrato(id):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        print(f'Intentando eliminar contrato con ID: {id}')
        cursor.callproc('eliminar_contrato', (id,))
        eliminado = 0

        for result in cursor.stored_results():
            eliminado = result.fetchone()[0]

        if eliminado > 0:
            conn.commit()
            print('Contrato eliminado exitosamente')
            flash('Contrato eliminado exitosamente', 'success')
        else:
            conn.rollback()
            print('El procedimiento no eliminó ningún contrato')
            flash('No se pudo eliminar el contrato', 'error')
    except Exception as e:
        conn.rollback()
        print(f'Error al eliminar contrato: {str(e)}')
        flash('Error al eliminar el contrato', 'error')
    finally:
        cursor.close()
        conn.close()

    return redirect(url_for('contrato.pt_gestion_contratos'))