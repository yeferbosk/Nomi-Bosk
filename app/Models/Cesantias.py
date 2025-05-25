# app/Models/Cesantias.py

from app import db

class Cesantias(db.Model):
    __tablename__ = 'Cesantias'
    id_cesantias = db.Column(db.Integer, primary_key=True)
    fecha_pago = db.Column(db.Date, nullable=False)
    valor = db.Column(db.Numeric(10, 2), nullable=False)
    id_empleado = db.Column(db.Integer, db.ForeignKey('Empleado.id_empleado'), nullable=False)

    empleado = db.relationship('Empleado', backref=db.backref('cesantias', lazy=True))
