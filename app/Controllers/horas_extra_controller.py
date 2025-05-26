from flask import jsonify, request
from app.Models.Horas_Extra import HorasExtra
from bson import json_util, ObjectId
import json
import traceback

class HorasExtraController:
    def __init__(self):
        try:
            self.horas_extra_model = HorasExtra()
        except Exception as e:
            print("Error al inicializar el controlador:", str(e))
            traceback.print_exc()
            raise

    def obtener_horas_extra(self):
        try:
            print("\n=== Obteniendo todas las horas extras ===")
            horas_extra = self.horas_extra_model.obtener_todas_horas_extra()
            print("Datos obtenidos de MongoDB:", horas_extra)
            
            # Convertir ObjectId a string para poder serializarlo
            datos_json = json.loads(json_util.dumps(horas_extra))
            print("Datos convertidos a JSON:", datos_json)
            
            return jsonify(datos_json)
        except Exception as e:
            print("Error al obtener horas extras:", str(e))
            traceback.print_exc()
            return jsonify({'error': str(e)}), 500

    def obtener_horas_extra_por_id(self, id):
        try:
            print(f"Obteniendo horas extras con ID: {id}")
            horas_extra = self.horas_extra_model.obtener_horas_extra_por_id(id)
            if not horas_extra:
                return jsonify({'error': 'No se encontró el registro'}), 404
            return json.loads(json_util.dumps(horas_extra))
        except Exception as e:
            print("Error al obtener horas extras por ID:", str(e))
            return jsonify({'error': str(e)}), 500

    def crear_horas_extra(self):
        try:
            print("\n=== Iniciando creación de horas extras ===")
            # Obtener y validar datos del request
            data = request.get_json()
            print("Datos recibidos en el request:", data)
            
            if not data:
                print("Error: No se recibieron datos en el request")
                return jsonify({'error': 'No se recibieron datos'}), 400

            # Validaciones básicas
            required_fields = ['id_empleado', 'fecha', 'cantidad', 'tipo', 'valor']
            missing_fields = [field for field in required_fields if field not in data]
            if missing_fields:
                error_msg = f"Campos requeridos faltantes: {', '.join(missing_fields)}"
                print("Error:", error_msg)
                return jsonify({'error': error_msg}), 400

            try:
                # Convertir tipos de datos
                data['id_empleado'] = int(data['id_empleado'])
                data['cantidad'] = int(data['cantidad'])
                data['valor'] = float(data['valor'])
            except ValueError as e:
                error_msg = f"Error al convertir tipos de datos: {str(e)}"
                print("Error:", error_msg)
                return jsonify({'error': error_msg}), 400

            print("Datos validados:", data)

            # Intentar crear el registro
            try:
                resultado = self.horas_extra_model.crear_horas_extra(data)
                print("Resultado de la creación:", resultado.inserted_id)
                
                # Verificar que se creó correctamente
                nuevo_registro = self.horas_extra_model.obtener_horas_extra_por_id(resultado.inserted_id)
                print("Nuevo registro creado:", nuevo_registro)
                
                return jsonify({
                    'message': 'Horas extra registradas correctamente',
                    'id': str(resultado.inserted_id),
                    'data': json.loads(json_util.dumps(nuevo_registro))
                }), 201
            except Exception as e:
                error_msg = f"Error al crear el registro en MongoDB: {str(e)}"
                print("Error:", error_msg)
                traceback.print_exc()
                return jsonify({'error': error_msg}), 500

        except Exception as e:
            print("Error general al crear horas extras:", str(e))
            traceback.print_exc()
            return jsonify({'error': str(e)}), 500

    def actualizar_horas_extra(self, id):
        try:
            print(f"\n=== Actualizando horas extras {id} ===")
            data = request.get_json()
            print("Datos recibidos para actualizar:", data)
            
            if not data:
                return jsonify({'error': 'No se recibieron datos'}), 400

            # Asegurar tipos de datos correctos
            if 'id_empleado' in data:
                data['id_empleado'] = int(data['id_empleado'])
            if 'cantidad' in data:
                data['cantidad'] = int(data['cantidad'])
            if 'valor' in data:
                data['valor'] = float(data['valor'])

            resultado = self.horas_extra_model.actualizar_horas_extra(id, data)
            print("Resultado de la actualización:", resultado.modified_count)
            
            if resultado.modified_count:
                return jsonify({'message': 'Registro actualizado correctamente'})
            return jsonify({'message': 'No se encontró el registro'}), 404
        except Exception as e:
            print("Error al actualizar horas extras:", str(e))
            traceback.print_exc()
            return jsonify({'error': str(e)}), 500

    def eliminar_horas_extra(self, id):
        try:
            print(f"\n=== Eliminando horas extras {id} ===")
            resultado = self.horas_extra_model.eliminar_horas_extra(id)
            print("Resultado de la eliminación:", resultado.deleted_count)
            
            if resultado.deleted_count:
                return jsonify({'message': 'Registro eliminado correctamente'})
            return jsonify({'message': 'No se encontró el registro'}), 404
        except Exception as e:
            print("Error al eliminar horas extras:", str(e))
            traceback.print_exc()
            return jsonify({'error': str(e)}), 500 