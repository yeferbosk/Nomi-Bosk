# app/Models/Vacaciones.py

from app import db

class Vacaciones(db.Model):
    __tablename__ = 'Vacaciones'
    id_vacaciones = db.Column(db.Integer, primary_key=True)
    fecha_inicio = db.Column(db.Date, nullable=False)
    fecha_fin = db.Column(db.Date, nullable=False)
    dias_vacaciones = db.Column(db.Integer, nullable=False)
    id_empleado = db.Column(db.Integer, db.ForeignKey('Empleado.id_empleado'), nullable=False)

    empleado = db.relationship('Empleado', backref=db.backref('vacaciones', lazy=True))
