# app/Models/Horas_Extra.py

from app import db

class HorasExtra(db.Model):
    __tablename__ = 'Horas_Extra'
    id_horaExtra = db.Column(db.Integer, primary_key=True)
    fecha = db.Column(db.Date, nullable=False)
    tipo = db.Column(db.String(50))
    cantidad = db.Column(db.Integer, nullable=False)
    valor = db.Column(db.Numeric(10, 2), nullable=False)
    id_empleado = db.Column(db.Integer, db.ForeignKey('Empleado.id_empleado'), nullable=False)

    empleado = db.relationship('Empleado', backref=db.backref('horas_extra', lazy=True))
