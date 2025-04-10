# app/Models/Empleado.py

from app import db

class Empleado(db.Model):
    __tablename__ = 'Empleado'
    id_empleado = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), nullable=False)
    fecha_nacimiento = db.Column(db.Date, nullable=False)
    telefono = db.Column(db.String(20))
    estado_civil = db.Column(db.String(20))
    genero = db.Column(db.String(10))
    n_documento = db.Column(db.String(20), nullable=False)
    cargo = db.Column(db.String(50))
    estado = db.Column(db.Boolean, default=True)
    direccion = db.Column(db.Text)
    fecha_ingreso = db.Column(db.Date, nullable=False)
