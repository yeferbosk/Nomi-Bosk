# app/controller/empleadocontroller.py

from flask import Blueprint, render_template, flash, request, redirect, url_for

#Dependencias app
from app.Models.Empleado import Empleado
from app import get_connection

empleado_bp = Blueprint('empleado_bp', __name__, url_prefix='/inicio/gestion_empleados')


#APARTADO PRINCIPAL DE EMPLEADOS

#End point gestion de empleados
@empleado_bp.route('/')
def pt_gestion_empleado():
    empleados = Empleado.query.all()
    return render_template('empleados/GestionEmpleado.html', empleados=empleados)

#End point crear empleado y contrato
@empleado_bp.route('/crear_empleado', methods=['GET', 'POST'])
def pt_crear_empleado():
    print("\n🔄 INICIANDO PROCESO DE CREAR EMPLEADO")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    if request.method == 'POST':
        print("📝 Método POST detectado - Procesando formulario")
        print("\n📋 Datos recibidos en el request:")
        print(f"Form data: {request.form}")
        print(f"Content Type: {request.content_type}")
        print(f"Headers: {request.headers}")
        
        try:
            print("\n1️⃣ Validando datos del formulario...")
            required_fields = ['nombre', 'email', 'fecha_nacimiento', 'telefono', 
                             'estado_civil', 'genero', 'n_documento', 'cargo',
                             'direccion', 'fecha_inicio', 'salario_bruto', 
                             'tipo', 'horario']
            
            missing_fields = [field for field in required_fields if not request.form.get(field)]
            if missing_fields:
                raise ValueError(f"Campos requeridos faltantes: {', '.join(missing_fields)}")

            # Obtener y validar datos del formulario
            nombre = request.form.get('nombre')
            email = request.form.get('email')
            fecha_nacimiento = request.form.get('fecha_nacimiento')
            telefono = request.form.get('telefono')
            estado_civil = request.form.get('estado_civil')
            genero = request.form.get('genero')
            n_documento = request.form.get('n_documento')
            cargo = request.form.get('cargo')
            estado = True
            direccion = request.form.get('direccion')
            fecha_ingreso = request.form.get('fecha_inicio')

            print('\n🔵 DATOS DEL FORMULARIO VALIDADOS 🔵')
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━')
            print(f'📝 Datos del empleado:')
            print(f'   • Nombre: {nombre}')
            print(f'   • Email: {email}')
            print(f'   • Documento: {n_documento}')
            print(f'   • Teléfono: {telefono}')
            print(f'   • Cargo: {cargo}')
            print(f'   • Fecha ingreso: {fecha_ingreso}')
            print(f'   • Fecha nacimiento: {fecha_nacimiento}')
            print(f'   • Género: {genero}')
            print(f'   • Estado civil: {estado_civil}')
            print(f'   • Dirección: {direccion}')

            # Datos del formulario contrato
            salario_bruto = request.form.get('salario_bruto')
            tipo = request.form.get('tipo')
            horario = request.form.get('horario')
            fecha_inicio = request.form.get('fecha_inicio')
            fecha_fin = request.form.get('fecha_fin')

            # Validar salario
            try:
                salario_bruto = float(salario_bruto)
                if salario_bruto <= 0:
                    raise ValueError("El salario debe ser mayor a 0")
            except (TypeError, ValueError) as e:
                raise ValueError(f"Salario inválido: {salario_bruto}. {str(e)}")

            print(f'\n📄 Datos del contrato:')
            print(f'   • Salario: ${salario_bruto}')
            print(f'   • Tipo: {tipo}')
            print(f'   • Horario: {horario}')
            print(f'   • Fecha inicio: {fecha_inicio}')
            print(f'   • Fecha fin: {fecha_fin if fecha_fin else "Indefinido"}')
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━')

            print("\n2️⃣ Conectando a la base de datos...")
            conn = get_connection()
            cursor = conn.cursor()

            print("3️⃣ Preparando argumentos para crear empleado...")
            args = (
                nombre, email, fecha_nacimiento, telefono,
                estado_civil, genero, n_documento, cargo,
                estado, direccion, fecha_ingreso
            )
            
            print("4️⃣ Ejecutando procedimiento crear_empleado...")
            print(f"Argumentos: {args}")
            cursor.callproc('crear_empleado', args)
            print("✅ Procedimiento ejecutado")
            
            print("5️⃣ Haciendo commit de la transacción...")
            conn.commit()
            print("✅ Commit realizado")
            
            print("6️⃣ Obteniendo ID del empleado creado...")
            cursor.execute("SELECT LAST_INSERT_ID()")
            result = cursor.fetchone()
            
            if result is not None:
                id_empleado = result[0]
                print(f"✅ ID del empleado obtenido: {id_empleado}")
                
                print("7️⃣ Creando contrato...")
                cursor.callproc("crear_contrato", (
                    salario_bruto, tipo, horario, fecha_inicio, fecha_fin, id_empleado
                ))
                conn.commit()
                print("✅ Contrato creado exitosamente")
                
                mensaje = f'Empleado "{nombre}" y su contrato fueron creados exitosamente (ID: {id_empleado})'
                print(f"🎉 {mensaje}")
                flash(mensaje, 'success')
                return redirect(url_for('empleado_bp.pt_gestion_empleado'))
            else:
                conn.rollback()
                mensaje = '❌ Error: No se pudo obtener el ID del empleado creado'
                print(mensaje)
                flash(mensaje, 'error')
            
        except ValueError as ve:
            print(f"\n❌ ERROR DE VALIDACIÓN:")
            print(f"Descripción: {str(ve)}")
            flash(f'Error de validación: {str(ve)}', 'error')
            
        except Exception as e:
            print(f"\n❌ ERROR DETECTADO:")
            print(f"Tipo de error: {type(e).__name__}")
            print(f"Descripción: {str(e)}")
            print("Detalles adicionales:", e.__dict__ if hasattr(e, '__dict__') else "No hay detalles adicionales")
            
            if 'conn' in locals():
                conn.rollback()
            mensaje = f'❌ Error al crear empleado o contrato: {str(e)}'
            flash(mensaje, 'error')
            
        finally:
            if 'cursor' in locals():
                print("\n🔄 Cerrando cursor...")
                cursor.close()
            if 'conn' in locals():
                print("🔄 Cerrando conexión...")
                conn.close()
            print("✅ Recursos liberados")
    else:
        print("📋 Método GET detectado - Mostrando formulario")
        
    # Obtener cargos disponibles
    print("\n🔄 Obteniendo lista de cargos...")
    conn = get_connection()
    cursor = conn.cursor()
    cursor.callproc('obtener_cargos')
    cargos = []
    for result in cursor.stored_results():
        cargos = [row[0] for row in result.fetchall() if row[0]]
    cursor.close()
    conn.close()
    print(f"📋 Cargos disponibles = {cargos}")

    return render_template('empleados/GestionEmpleadoAgregar.html', cargos=cargos)

#End point para editar empleado y contrato
@empleado_bp.route('/editar/<int:id>', methods=['GET', 'POST'])
def pt_editar_empleado(id):
    conn = get_connection()
    cursor = conn.cursor()

    #Traer datos del empleado para editar
    cursor.callproc('obtener_empleado_por_id', (id,))
    empleado = None

    for result in cursor.stored_results():
        row = result.fetchone()
        if row:
            empleado = {
                'id_empleado': row[0],
                'email': row[1],
                'nombre': row[2],
                'fecha_nacimiento': row[3],
                'telefono': row[4],
                'estado_civil': row[5],
                'genero': row[6],
                'n_documento': row[7],
                'cargo': row[8],
                'estado': row[9],
                'direccion': row[10],
                'fecha_ingreso': row[11]
            }

    print(f'Empleado = {empleado}')

    # Traer datos de contrato para editar
    cursor.callproc('obtener_contrato_por_id_empleado', (id,))
    contrato = None

    for result in cursor.stored_results():
        row = result.fetchone()
        if row:
            contrato = {
                'id_contrato': row[0],
                'salario_bruto': row[1],
                'tipo': row[2],
                'horario': row[3],
                'fecha_inicio': row[4],
                'fecha_fin': row[5],
                'id_empleado': row[6]
            }

    print(f'Contrato = {contrato}')

    # Traer datos de cargos
    cursor.callproc('obtener_cargos')
    cargos = []
    for result in cursor.stored_results():
        cargos = [row[0] for row in result.fetchall()]
    
    print(f'Cargos = {cargos}')
    cursor.close()
    conn.close()

    if request.method == 'POST':
        print('Recibiendo datos del formulario para editar empleado y contrato')
        #Abrir conexion de nuevo
        conn = get_connection()
        cursor = conn.cursor()

        # Recoger datos del formulario empleado
        nombre = request.form['nombre']
        n_documento = request.form['n_documento']
        email = request.form['email']
        telefono = request.form['telefono']
        cargo = request.form['cargo']
        fecha_ingreso = request.form['fecha_ingreso']
        fecha_nacimiento = request.form['fecha_nacimiento']
        genero = request.form['genero']
        estado_civil = request.form['estado_civil']
        estado = int(request.form['estado'])
        direccion = request.form['direccion']

        print(f'Datos empleado = {nombre}, {n_documento}, {email}, {telefono}, {cargo}, {fecha_ingreso}, {fecha_nacimiento}, {genero}, {estado_civil}, {estado}, {direccion}')

        # Recoger datis del formulario contrato
        salario_bruto = float(request.form['salario_bruto'])
        tipo = request.form['tipo']
        horario = request.form['horario']
        fecha_inicio = request.form['fecha_inicio']
        fecha_fin = request.form['fecha_fin'] or None

        print(f'Datos contrato = {salario_bruto}, {tipo}, {horario}, {fecha_inicio}, {fecha_fin}')

        # Ejecutar procedimiento para actualizar empleado
        cursor.callproc('actualizar_empleado', (
                    id, nombre, n_documento, email, telefono, cargo,
                    fecha_ingreso, fecha_nacimiento, genero, estado_civil,
                    estado, direccion
        ))

        # Ejecutar procedimiento para actualizar contrato
        cursor.callproc('actualizar_contrato', (
                    contrato['id_contrato'], salario_bruto, tipo, horario,
                    fecha_inicio, fecha_fin
        ))

        
        conn.commit()
        cursor.close()
        conn.close()

        return redirect(url_for('empleado_bp.pt_gestion_empleado'))

        
    return render_template('empleados/GestionEmpleadoEditar.html', empleado=empleado, contrato=contrato, cargos=cargos)

@empleado_bp.route('/eliminar/<int:id>', methods=['POST'])
def pt_eliminar_empleado(id):
    conn = get_connection()
    cursor = conn.cursor()
    
    try:
        # Eliminamos contrato del empleado
        cursor.callproc('eliminar_contrato_por_empleado', (id,))
        contrato_eliminado = 0
        for result in cursor.stored_results():
            contrato_eliminado = result.fetchone()[0]
        
        # Cambiamos el estado de empleado a inactivo
        cursor.callproc('desactivar_empleado', (id,))
        empleado_desactivado = 0
        for result in cursor.stored_results():
            empleado_desactivado = result.fetchone()[0]
        
        if contrato_eliminado >= 0 and empleado_desactivado > 0:
            conn.commit()
            print('Empleado desactivado y contrato eliminado correctamente')
        else:
            conn.rollback()
            print('No se pudo completar la operación')
            
    except Exception as e:
        conn.rollback()
        print(f'Error al eliminar: {str(e)}')
        print(f"Error en eliminación lógica: {str(e)}")
        
    finally:
        cursor.close()
        conn.close()
    
    return redirect(url_for('empleado_bp.pt_gestion_empleado'))