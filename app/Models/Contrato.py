# app/Models/Contrato.py

from app import db

class Contrato(db.Model):
    __tablename__ = 'Contrato'
    id_contrato = db.Column(db.Integer, primary_key=True)
    salario_bruto = db.Column(db.Numeric(10, 2), nullable=False)
    tipo = db.Column(db.String(50))
    horario = db.Column(db.String(50))
    fecha_inicio = db.Column(db.Date, nullable=False)
    fecha_fin = db.Column(db.Date, nullable=True)
    id_empleado = db.Column(db.Integer, db.ForeignKey('Empleado.id_empleado'), nullable=False)

    empleado = db.relationship('Empleado', backref=db.backref('contratos', lazy=True))
