# app/controller/contratocontroller.py

from flask import Blueprint, render_template, request, redirect, url_for
from app import get_connection

contrato_bp = Blueprint('contrato_bp', __name__, url_prefix='/inicio/gestion_contratos')


@contrato_bp.route('/')
def pt_gestion_contratos():
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.callproc('obtener_contratos')
        contratos = []

        for result in cursor.stored_results():
            column_names = [desc[0] for desc in result.description]
            contratos = [dict(zip(column_names, row)) for row in result.fetchall()]

        print(f'Contratos obtenidos: {contratos}')
    except Exception as e:
        print(f'Error al obtener contratos: {str(e)}')
        contratos = []
    finally:
        cursor.close()
        conn.close()

    return render_template('contratos/GestionContrato.html', contratos=contratos)

# Nuevo endpoint para eliminar contrato
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
        else:
            conn.rollback()
            print('El procedimiento no eliminó ningún contrato')
    except Exception as e:
        conn.rollback()
        print(f'Error al eliminar contrato: {str(e)}')
    finally:
        cursor.close()
        conn.close()

    return redirect(url_for('contrato_bp.pt_gestion_contratos'))
