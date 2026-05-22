async function vaidateIncidenciaSalida(req, res, next) {
    //SYNTAX_ERROR
    // console.log(req.body);
    const { nomina, auto, placa, motivo, acompanantesQTY, telefono, regresa, hora_salida, hora_regreso, lugar, descripcion, acompanante1, acompanante2, acompanante3, acompanante4, acompanante5 } = req.body;
    // console.log(nomina);
    next();
}
module.exports = {
    vaidateIncidenciaSalida
}