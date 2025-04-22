# app/Models/Liquidacion.py

from app import db

class Liquidacion(db.Model):
    __tablename__ = 'Liquidacion'
    id_liquidacion = db.Column(db.Integer, primary_key=True)
    tipo_pago = db.Column(db.String(50))
    fecha_pago = db.Column(db.Date, nullable=False)
    prima_servicios = db.Column(db.Numeric(10, 2))
    total_pago = db.Column(db.Numeric(10, 2), nullable=False)
    id_empleado = db.Column(db.Integer, db.ForeignKey('Empleado.id_empleado'), nullable=False)

    empleado = db.relationship('Empleado', backref=db.backref('liquidaciones', lazy=True))
