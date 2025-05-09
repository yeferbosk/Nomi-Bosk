
📄 README - Configuración del Proyecto Flask de Nómina

👋 ¡Bienvenido/a! Aquí aprenderás a clonar este proyecto, configurar el entorno virtual y ejecutar la aplicación correctamente.

🚀 PASOS PARA INICIAR

1️⃣ Clonar el repositorio
--------------------------
Abre tu terminal y ejecuta:

```bash
git clone https://github.com/usuario/proyecto-nomina.git
cd proyecto-nomina
```

2️⃣ Crear y activar el entorno virtual
---------------------------------------
En Windows:

```bash
python -m venv venv
venv\Scripts\activate
```

En Linux/Mac:

```bash
python3 -m venv venv
source venv/bin/activate
```

Activa el entorno virtual con el comando 

venv\Scripts\Activate

En caso de querer desactivar el entorno virtual lo puedes hacer con el comando

deactivate

(Ten encuenta que todas las dependencias se deebne instalar con el entorno virtual activo).

3️⃣ Instalar las dependencias
------------------------------
Primero asegúrate de tener un archivo llamado `requirements.txt` en el proyecto. Luego ejecuta:

```bash
pip install -r requirements.txt
```

📌 Si por alguna razón falla la instalación desde el archivo, instala las dependencias manualmente con el siguiente comando:

```bash
pip install blinker==1.9.0 click==8.1.8 colorama==0.4.6 Flask==3.1.0 Flask-SQLAlchemy==3.1.1 greenlet==3.1.1 itsdangerous==2.2.0 Jinja2==3.1.6 MarkupSafe==3.0.2 mysql-connector-python==9.2.0 PyMySQL==1.1.1 SQLAlchemy==2.0.40 typing_extensions==4.13.2 Werkzeug==3.1.3
```

4️⃣ Ejecutar la aplicación Flask
---------------------------------
Con el entorno activado, ejecuta:

```bash
python run.py
```

✅ ¡Listo! Si todo está correcto, tu aplicación Flask estará corriendo en `http://localhost:5000`.
🔚 Fin del README
------------------
Gracias por usar este proyecto. ¡Que tengas una gran experiencia desarrollando! 🧑‍💻✨
