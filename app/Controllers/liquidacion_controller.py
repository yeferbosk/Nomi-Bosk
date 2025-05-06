from app import get_connection
from decimal import Decimal
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta


def crear_liquidacion(data):
    conn = get_connection()
    cursor = conn.cursor()
    # Ya no calculas la fecha en el backend
    cursor.callproc('crear_liquidacion_nomina', [
        data['id_empleado'],
        data['tipo_pago']
    ])
    conn.commit()
    cursor.close()
    conn.close()


def obtener_liquidaciones():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
    SELECT 
        l.id_liquidacion,
        e.nombre,
        e.n_documento,
        e.cargo,
        l.tipo_pago,
        DATE_FORMAT(l.fecha_pago, '%Y-%m-%d') as fecha_pago,
        c.salario_bruto as salario_base,
        h.cantidad as horas_extra,
        l.prima_servicios,
        ss.salud,
        ss.pension,
        l.total_devengado, 
        l.total_deducciones,
        l.auxilio_transporte,           
        l.total_pago           
    FROM Liquidacion l
    JOIN Empleado e ON l.id_empleado = e.id_empleado
    JOIN Contrato c ON c.id_empleado = e.id_empleado 
    LEFT JOIN Horas_Extra h ON h.id_empleado = e.id_empleado
    LEFT JOIN Seguridad_Social ss ON ss.id_empleado = e.id_empleado
    ORDER BY l.fecha_pago DESC
    """)
    liquidaciones = cursor.fetchall()
    cursor.close()
    conn.close()
    return liquidaciones
