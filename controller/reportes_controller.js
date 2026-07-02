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
async function getExcelReport(req, res) {
    const workbook = new ExcelJS.Workbook();
    const { fecha1, fecha2, tipo, estatus } = req.query;
    let worksheet, result, data;
    try{
        switch(tipo){
            case '1': //incidencias tipo salidas
            worksheet = workbook.addWorksheet("incidencias_salidas");
            result = await pool.query('select * from rh.fn_reporte_salidas($1,$2,$3,$4);', [
                fecha1, fecha2, tipo, estatus
            ]);
            data = result.rows
            // console.log(data);
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
            // worksheet.addRow(
            //     {"v_id": 1, "v_nomina": 4436, "v_tipoauto": "NA", "v_placas": "XXX-XXX", "v_motivo": "Enfermedad", "v_tel": "4428304862", "v_regresa": "Si", "v_h_salida": "9:00", "v_h_regreso": "14:00", "v_lugar": "Por hay", "v_descripcion": "Jijiji", "v_obs": "observaciones", "v_acompqty": 1, "v_a1": 1, "v_a2": 0, "v_a3": 0, "v_a4": 0, "v_a5": 0}
            // );
            data.forEach(element => {
                // console.log(element.v_id);
                worksheet.addRow({
                    v_id: element.v_id,
                    v_nomina: element.v_nomina,
                    v_tipoauto: element.v_tipoauto,
                    v_placas: element.v_placas,
                    v_motivo: element.v_motivo,
                    v_tel: element.v_tel,
                    v_regresa: element.v_regresa,
                    v_h_salida: element.v_h_salida,
                    v_h_regreso: element.v_h_regreso,
                    v_lugar: element.v_lugar,
                    v_descripcion: element.v_descripcion,
                    v_obs: element.v_obs,
                    v_acompqty: element.v_acompqty,
                    v_a1: element.v_a1,
                    v_a2: element.v_a2,
                    v_a3: element.v_a3,
                    v_a4: element.v_a4,
                    v_a5: element.v_a5,
                })
            });
            res.setHeader(
                'Content-Type',
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
            );
            res.setHeader(
                'Content-Disposition',
                'attachment; filename=' + 'incidencias_salidas.xlsx'
            );
            await workbook.xlsx.write(res);
            res.end();
            break;
            case '2':
                worksheet = workbook.addWorksheet("incidencias_ausencias");
                // console.log(fecha1)
                result = await pool.query('select * from rh.fn_reporte_ausencias($1,$2,$3)',[
                    fecha1, fecha2, estatus
                ]);
                data = result.rows;
                worksheet.columns = [
                    { header: "ID", key: "v_id", width: 20},
                    { header: "Nomina", key: "v_useridf", width: 20},
                    { header: "Motivo", key: "v_motivo", width: 20},
                    { header: "Goce", key: "v_goce", width: 20},
                    { header: "Vacaciones", key: "v_uso_vacacion", width: 20},
                    { header: "Telefono", key: "v_tel", width: 20},
                    { header: "Dias de ausencia", key: "v_diasqty", width: 20},
                    { header: "Fecha inicio", key: "v_fecha_ini", width: 20},
                    { header: "Fecha regreso", key: "v_fecha_fin", width: 20},
                    { header: "Autoriza", key: "v_autoriza", width: 20},
                    { header: "VoBo", key: "v_vobo", width: 20},
                    { header: "Descripcion", key: "v_descripcion", width: 20},
                    { header: "Observaciones", key: "v_observaciones", width: 20},
                ]
                data.forEach(element => {
                    worksheet.addRow({
                        v_id: element.v_id,
                        v_useridf: element.v_useridf,
                        v_motivo: element.v_motivo,
                        v_goce: element.v_goce,
                        v_uso_vacacion: element.v_uso_vacacion,
                        v_tel: element.v_tel,
                        v_diasqty: element.v_diasqty,
                        v_fecha_ini: element.v_fecha_ini,
                        v_fecha_fin: element.v_fecha_fin,
                        v_autoriza: element.v_autoriza,
                        v_vobo: element.v_vobo,
                        v_descripcion: element.v_descripcion,
                        v_observaciones: element.v_observaciones
                    });
                });

                 res.setHeader(
                    'Content-Type',
                    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                );
                res.setHeader(
                    'Content-Disposition',
                    'attachment; filename=' + 'incidencias_ausencia.xlsx'
                );
                await workbook.xlsx.write(res);
                res.end();
                break;
            default:
                break;
        }
        //una vez que se obtiene la data. se genera el excel
        
    }catch(err){
        console.error(err);
    }
}
async function getReporteVigilancia(req, res) {
    try{
        const result = await pool.query('select * from rh.fn_gettablavigilancia();');

        res.status(200).json(result.rows);

    }catch(err){
        console.error(err)
    }
}
module.exports = {
    getReport,
    getExcelReport,
    getReporteVigilancia
}