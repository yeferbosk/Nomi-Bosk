function mostrarCampoFiltro() {
    const tipo = document.getElementById('filterType').value;

    // Ocultar todos los campos de filtro
    document.getElementById('campoCargo').style.display = 'none';
    document.getElementById('campoSalario').style.display = 'none';
    document.getElementById('campoFecha').style.display = 'none';

    // Mostrar el campo correspondiente según el tipo de filtro
    if (tipo === 'CARGO') {
        document.getElementById('campoCargo').style.display = 'block';
    } else if (tipo === 'SALARIO') {
        document.getElementById('campoSalario').style.display = 'block';
    } else if (tipo === 'FECHA') {
        document.getElementById('campoFecha').style.display = 'block';
    }
}

function aplicarFiltros() {
    const tipo = document.getElementById('filterType').value;
    let valor = '';
    let operador = null;

    if (tipo === 'CARGO') {
        valor = document.getElementById('filterCargo').value;
    } else if (tipo === 'SALARIO') {
        valor = document.getElementById('filterSalario').value;
        operador = document.getElementById('salarioOperador').value;
    } else if (tipo === 'FECHA') {
        valor = document.getElementById('filterFecha').value;
    }

    // Validación básica
    if (!tipo || !valor) {
        alert('Por favor complete todos los campos requeridos.');
        return;
    }

    fetch('/filtrar_empleados', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            tipo_filtro: tipo,
            valor_filtro: valor,
            operador_salario: operador
        })
    })
    .then(response => response.json())
    .then(data => {
        const tablaBody = document.querySelector('#tabla-empleados tbody');
        tablaBody.innerHTML = '';  // Limpia la tabla antes de agregar las filas

        data.forEach(empleado => {
            const fila = `
                <tr>
                    <td>${empleado.nombre}</td>
                    <td>${empleado.cargo}</td>
                    <td>${empleado.salario_base}</td>
                    <td>${empleado.fecha_pago}</td>
                </tr>
            `;
            tablaBody.innerHTML += fila;  // Agrega una nueva fila por cada empleado filtrado
        });

        // Opcional: cerrar el modal después de aplicar los filtros
        const modal = bootstrap.Modal.getInstance(document.getElementById('filterModal'));
        modal.hide();
    })
    .catch(error => console.error('Error al aplicar filtros:', error));
}
