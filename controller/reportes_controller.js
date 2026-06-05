const { pool } = require('../database');
const ExcelJS = require('exceljs/dist/es5')

async function getReport(req, res) {
    try{
        const { fecha1, fecha2, tipo, estatus } = req.query;
        // console.log(req.query);
        // console.log(tipo);
        let result;
        switch(tipo){
            case '1': //incidencias tipo salidas
                result = await pool.query('select * from rh.fn_reporte_salidas($1,$2,$3,$4);', [
                    fecha1, fecha2, tipo, estatus
                ]);
                // console.log("entra aqui")
                break;
            case '2':
                console.log(fecha1)
                result = await pool.query('select * from rh.fn_reporte_ausencias($1,$2,$3)',[
                    fecha1, fecha2, estatus
                ]);
                break;
            default:
                break;
        }
        // console.log(result)
        res.status(200).json(result.rows);
    }catch(err){
        console.error(err);
    }
}
async function getDataToExcel(req, res) {
    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet("incidencias");
    const { fecha1, fecha2, tipo, estatus } = req.query;
    let result;
    try{
        switch(tipo){
            case '1': //incidencias tipo salidas
                result = await pool.query('select * from rh.fn_reporte_salidas($1,$2,$3,$4);', [
                    fecha1, fecha2, tipo, estatus
                ]);
                let data = result.rows
                // console.log("entra aqui")
                worksheet.columns = [
                    { header: "ID", key: "v_id", width: 20 },
                    { header: "Nomina", key: "v_nomina", width: 20 },
                    { header: "Tipo Auto", key: "v_tipoauto", width: 20 },
                    { header: "Placas", key: "v_placas", width: 20 },
                    { header: "Motivo", key: "v_motivo", width: 20 },
                    { header: "Telefono", key: "v_tel", width: 20 },
                    { header: "Regresa", key: "v_regresa", width: 20 },
                    { header: "Hora Salida", key: "v_h_salida", width: 20 },
                    { header: "Hora Regresp", key: "v_h_regreso", width: 20 },
                    { header: "Destino", key: "v_lugar", width: 20 },
                    { header: "Descripcion", key: "v_descripcion", width: 20 },
                    { header: "Observaciones", key: "v_obs", width: 20 },
                    { header: "Cantidad acompañantes", key: "v_acompqty", width: 20 },
                    { header: "Acompañante 1", key: "v_a1", width: 20 },
                    { header: "Acompañante 2", key: "v_a2", width: 20 },
                    { header: "Acompañante 3", key: "v_a3", width: 20 },
                    { header: "Acompañante 4", key: "v_a4", width: 20 },
                    { header: "Acompañante 5", key: "v_a5", width: 20 }
                ];

                break;
            case '2':
                console.log(fecha1)
                result = await pool.query('select * from rh.fn_reporte_ausencias($1,$2,$3)',[
                    fecha1, fecha2, estatus
                ]);
                break;
            default:
                break;
        }
        //una vez que se obtiene la data. se genera el excel
        
    }catch(err){
        console.error(err);
    }
}

module.exports = {
    getReport
}