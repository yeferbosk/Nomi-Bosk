from datetime import datetime

from flask import Blueprint, flash, redirect, request, url_for

from app import db
from app.Models.Vacaciones import Vacaciones

vacaciones_bp = Blueprint('vacaciones_bp', __name__)

@vacaciones_bp.route('/insertar-vacaciones', methods=['POST'])
def insertar_vacaciones():
    try:
        print("Iniciando proceso de registro de vacaciones...")
        
        # Obtener datos del formulario
        id_empleado = request.form.get('id_empleado')
        fecha_inicio = request.form.get('fecha_inicio')
        fecha_fin = request.form.get('fecha_fin')
        
        print(f"Datos recibidos - ID Empleado: {id_empleado}, Fecha Inicio: {fecha_inicio}, Fecha Fin: {fecha_fin}")
        
        if not all([id_empleado, fecha_inicio, fecha_fin]):
            raise ValueError("Todos los campos son requeridos")
            
        fecha_inicio = datetime.strptime(fecha_inicio, '%Y-%m-%d')
        fecha_fin = datetime.strptime(fecha_fin, '%Y-%m-%d')
        
        # Calcular días de vacaciones
        dias_vacaciones = (fecha_fin - fecha_inicio).days + 1
        print(f"Días de vacaciones calculados: {dias_vacaciones}")
        
        # Crear nueva instancia de Vacaciones
        nueva_vacacion = Vacaciones(
            id_empleado=id_empleado,
            fecha_inicio=fecha_inicio,
            fecha_fin=fecha_fin,
            dias_vacaciones=dias_vacaciones,
            valor=0  # El valor se calculará después con el procedimiento almacenado
        )
        
        print("Guardando en la base de datos...")
        # Guardar en la base de datos
        db.session.add(nueva_vacacion)
        db.session.commit()
        print("Registro guardado exitosamente")
        
        print("Calculando valor de vacaciones...")
        # Llamar al procedimiento almacenado para calcular el valor
        conn = db.engine.raw_connection()
        cursor = conn.cursor()
        cursor.callproc('CalcularNominaVacacional', [id_empleado])
        conn.commit()
        cursor.close()
        conn.close()
        print("Valor de vacaciones calculado")
        
        flash('Vacaciones registradas exitosamente', 'success')
        print("Proceso completado exitosamente")
        
    except ValueError as ve:
        print(f"Error de validación: {str(ve)}")
        db.session.rollback()
        flash(f'Error de validación: {str(ve)}', 'error')
    except Exception as e:
        print(f"Error inesperado: {str(e)}")
        db.session.rollback()
        flash(f'Error al registrar vacaciones: {str(e)}', 'error')
    
    return redirect(url_for('empleado_bp.pt_gestion_empleado'))     
