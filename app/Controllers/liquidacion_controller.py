from app import get_connection

def crear_liquidacion(data):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.callproc('crear_liquidacion_nomina_detallada', [
        data['id_empleado'],
        data['tipo_pago'],
        data['fecha_pago']
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
        l.fecha_pago,
        c.salario_bruto as salario_base,
        l.auxilio_transporte,
        h.cantidad as horas_extra,
        l.prima_servicios,
        l.total_devengado,
        l.salud,
        l.pension,
        l.total_deducciones,
        l.total_pago
    FROM Liquidacion l
    JOIN Empleado e ON l.id_empleado = e.id_empleado
    JOIN Contrato c ON c.id_empleado = e.id_empleado 
    LEFT JOIN Horas_Extra h ON h.id_empleado = e.id_empleado                 
    ORDER BY l.fecha_pago DESC
""")

    liquidaciones = cursor.fetchall()
    cursor.close()
    conn.close()
    return liquidaciones
