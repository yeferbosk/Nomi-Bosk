from app import db


class Bonos(db.Model):
    __tablename__ = 'bonos'
    id_bono = db.Column(db.Integer, primary_key=True)
    id_empleado = db.Column(db.Integer, db.ForeignKey('Empleado.id_empleado'), nullable=False)
    id_tipo_bono = db.Column(db.Integer, db.ForeignKey('tipos_bonos.id_tipo_bono'), nullable=False)
    fecha_bono = db.Column(db.Date, nullable=False)
    valor_bono = db.Column(db.Numeric(10, 2), nullable=False)
    porcentaje_cumplimiento = db.Column(db.Numeric(5, 2))
    observaciones = db.Column(db.Text)

    # Relationships
    empleado = db.relationship('Empleado', back_populates='bonos')
    tipo_bono = db.relationship('TiposBonos', backref='bonos') 