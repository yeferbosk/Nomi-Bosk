from app import db


class TiposBonos(db.Model):
    __tablename__ = 'tipos_bonos'
    id_tipo_bono = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(50), nullable=False)
    descripcion = db.Column(db.Text)
    es_constitutivo_salario = db.Column(db.Boolean, default=True) 