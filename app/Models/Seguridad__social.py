# app/Models/Seguridad_Social.py

from app import db

class SeguridadSocial(db.Model):
    __tablename__ = 'Seguridad_Social'
    id_seguridadSocial = db.Column(db.Integer, primary_key=True)
    salud = db.Column(db.String(50))
    riesgos_laborales = db.Column(db.String(50))
    caja_compensacion = db.Column(db.String(50))
    pension = db.Column(db.String(50))
    id_empleado = db.Column(db.Integer, db.ForeignKey('Empleado.id_empleado'), nullable=False)

    empleado = db.relationship('Empleado', backref=db.backref('seguridad_social', lazy=True))
    