from datetime import datetime
from pymongo import MongoClient
from bson import ObjectId
import sys
import time

class HorasExtra:
    def __init__(self):
        self.max_retries = 3
        self.retry_delay = 2  # segundos
        
        # Lista de URIs para intentar
        uris_to_try = [
            'mongodb://localhost:27017/',
            'mongodb://127.0.0.1:27017/',
            'mongodb://0.0.0.0:27017/',
            # Si tienes autenticación, descomenta la siguiente línea y ajusta las credenciales
            # 'mongodb://usuario:contraseña@localhost:27017/'
        ]
        
        last_error = None
        for uri in uris_to_try:
            for attempt in range(self.max_retries):
                try:
                    print(f"\n=== Intentando conectar a MongoDB usando URI: {uri} (Intento {attempt + 1}) ===")
                    
                    # Configuración de la conexión
                    self.client = MongoClient(
                        uri,
                        serverSelectionTimeoutMS=5000,
                        connectTimeoutMS=5000,
                        socketTimeoutMS=5000
                    )
                    
                    # Verificar la conexión
                    server_info = self.client.server_info()
                    print("Información del servidor MongoDB:")
                    print(f"- Versión: {server_info.get('version')}")
                    print(f"- Host: {self.client.address}")
                    
                    # Listar bases de datos disponibles
                    databases = self.client.list_database_names()
                    print("Bases de datos disponibles:", databases)
                    
                    # Seleccionar o crear base de datos y colección
                    self.db = self.client['nomina_db']
                    self.collection = self.db['horas_extra']
                    
                    # Verificar acceso a la colección
                    doc_count = self.collection.count_documents({})
                    print(f"Documentos en la colección horas_extra: {doc_count}")
                    
                    if doc_count > 0:
                        print("\nDocumentos actuales en la colección:")
                        for doc in self.collection.find():
                            print(doc)
                    else:
                        print("\nLa colección está vacía. Creando documento de prueba...")
                        test_doc = {
                            'id_empleado': 1,
                            'fecha': '2024-02-20',
                            'tipo': 'Diurna',
                            'cantidad': 4,
                            'valor': 15000
                        }
                        self.collection.insert_one(test_doc)
                        print("Documento de prueba creado.")
                    
                    print("\n¡Conexión exitosa a MongoDB!")
                    return  # Si llegamos aquí, la conexión fue exitosa
                    
                except Exception as e:
                    last_error = e
                    print(f"Error al intentar conectar a {uri}:", str(e), file=sys.stderr)
                    if attempt < self.max_retries - 1:
                        print(f"Reintentando en {self.retry_delay} segundos...")
                        time.sleep(self.retry_delay)
        
        # Si llegamos aquí, ninguna conexión funcionó
        print("\n=== ERROR: No se pudo conectar a MongoDB ===")
        print("Se intentaron las siguientes URIs:", uris_to_try)
        print("Último error:", str(last_error))
        raise last_error

    def crear_horas_extra(self, data):
        try:
            print("\n=== Creando nuevo registro de horas extras ===")
            print("Datos recibidos:", data)
            
            # Validar que los campos requeridos estén presentes
            required_fields = ['id_empleado', 'fecha', 'cantidad', 'tipo', 'valor']
            for field in required_fields:
                if field not in data:
                    raise ValueError(f"Campo requerido faltante: {field}")
            
            # Asegurar que los tipos de datos sean correctos
            data['id_empleado'] = int(data['id_empleado'])
            data['cantidad'] = int(data['cantidad'])
            data['valor'] = float(data['valor'])
            data['fecha_creacion'] = datetime.now()
            
            print("Datos validados:", data)
            print(f"Usando base de datos: {self.db.name}")
            print(f"Usando colección: {self.collection.name}")
            
            # Insertar el documento
            resultado = self.collection.insert_one(data)
            print("Documento insertado con ID:", resultado.inserted_id)
            
            # Verificar que el documento se insertó correctamente
            nuevo_doc = self.collection.find_one({'_id': resultado.inserted_id})
            if nuevo_doc:
                print("Documento insertado correctamente:", nuevo_doc)
            else:
                raise Exception("El documento no se insertó correctamente")
            
            return resultado
        except Exception as e:
            print("Error al crear horas extras:", str(e), file=sys.stderr)
            raise

    def obtener_todas_horas_extra(self):
        try:
            print("\n=== Obteniendo todas las horas extras ===")
            # Asegurar que estamos usando la colección correcta
            print(f"Usando base de datos: {self.db.name}")
            print(f"Usando colección: {self.collection.name}")
            
            # Obtener todos los documentos
            documentos = list(self.collection.find())
            print(f"Se encontraron {len(documentos)} documentos")
            
            # Mostrar cada documento encontrado
            for doc in documentos:
                print("Documento encontrado:", doc)
            
            return documentos
        except Exception as e:
            print("Error al obtener horas extras:", str(e), file=sys.stderr)
            raise

    def obtener_horas_extra_por_id(self, id):
        try:
            print(f"\n=== Buscando documento con ID: {id} ===")
            documento = self.collection.find_one({'_id': ObjectId(id)})
            print("Documento encontrado:", documento)
            return documento
        except Exception as e:
            print("Error al obtener horas extras por ID:", str(e), file=sys.stderr)
            raise

    def actualizar_horas_extra(self, id, data):
        try:
            print(f"\n=== Actualizando documento {id} ===")
            print("Datos a actualizar:", data)
            
            data['fecha_actualizacion'] = datetime.now()
            resultado = self.collection.update_one(
                {'_id': ObjectId(id)},
                {'$set': data}
            )
            print("Resultado de la actualización:", {
                'matched_count': resultado.matched_count,
                'modified_count': resultado.modified_count
            })
            return resultado
        except Exception as e:
            print("Error al actualizar horas extras:", str(e), file=sys.stderr)
            raise

    def eliminar_horas_extra(self, id):
        try:
            print(f"\n=== Eliminando documento con ID: {id} ===")
            resultado = self.collection.delete_one({'_id': ObjectId(id)})
            print("Resultado de la eliminación:", {
                'deleted_count': resultado.deleted_count
            })
            return resultado
        except Exception as e:
            print("Error al eliminar horas extras:", str(e), file=sys.stderr)
            raise 