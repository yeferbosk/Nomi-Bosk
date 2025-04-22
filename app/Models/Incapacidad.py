# app/Models/Incapacidad.py

from app import db

class Incapacidad(db.Model):
    __tablename__ = 'Incapacidad'
    id_incapacidad = db.Column(db.Integer, primary_key=True)
    tipo = db.Column(db.String(50))
    fecha_inicio = db.Column(db.Date, nullable=False)
    fecha_fin = db.Column(db.Date, nullable=False)
    dias_incapacidad = db.Column(db.Integer)
    porcentaje_pago = db.Column(db.Numeric(5, 2))
    id_empleado = db.Column(db.Integer, db.ForeignKey('Empleado.id_empleado'), nullable=False)

    empleado = db.relationship('Empleado', backref=db.backref('incapacidades', lazy=True))
