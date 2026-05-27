const numberRegex = /^\d+$/;
const hourRegex = /^([01]\d|2[0-3]):[0-5]\d$/;
const fechaRegex = /^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/;

async function validateSalida(req, res, next) {
    //SYNTAX_ERROR
    // console.log(req.body);
    // const salidaFormulario = req.body;
    const { nomina, acompanantesQTY, hora_salida, regresa, hora_regreso, lugar, acompanante1, acompanante2, acompanante3, acompanante4, acompanante5 } = req.body;

    let acompanantes = [acompanante1, acompanante2, acompanante3, acompanante4, acompanante5];

    if(!numberRegex.test(nomina)){
        return res.status(422).json({
            "error": "El campo nomina es incorrecto o esta vacio",
            "code": "SYNTAX_ERROR"
        });
    }
    if(!hourRegex.test(hora_salida)){
        return res.status(422).json({
            "error": "El campo hora de salida es incorrecto o esta vacio",
            "code": "SYNTAX_ERROR"
        });
    }
    if(regresa == 1){
        if(!hourRegex.test(hora_regreso)){
            return res.status(422).json({
                "error": "El campo hora de regreso es incorrecto o esta vacio",
                "code": "SYNTAX_ERROR"
            });
        }
    }
    
    if(acompanantesQTY > 0){
        for(let i = 0; i < acompanantesQTY; i ++){
            if(!numberRegex.test(acompanantes[i])){
                return res.status(422).json({
                    "error": "El campo del acompañante " + (i+1) + " es incorrecto o esta vacio",
                    "code": "SYNTAX_ERROR"
                });
            }
        }
    }
    if(lugar == ''){
        return res.status(422).json({
            "error": "Se requiere ingrese un destino en el campo lugar destino",
            "code": "SYNTAX_ERROR"
        });
    }
    

    next();
}

async function validateAusencia(req, res, next) {
    const { motivo, telefono, fecha_ini, fecha_fin, descripcion } = req.body;

    if(motivo == ''){
        return res.status(422).json({
            "error": "El campo motivo es obligatorio",
            "code": "SYNTAX_ERROR"
        });
    }
    if(!numberRegex.test(telefono)){
        return res.status(422).json({
            "error": "El campo telefono es incorrecto",
            "code": "SYNTAX_ERROR"
        });
    }
    if(!fechaRegex.test(fecha_ini) || !fechaRegex.test(fecha_fin)){
        return res.status(422).json({
            "error": "El formato de las fechas es incorrecto",
            "code": "SYNTEX_ERROR"
        });
    }
    if(descripcion == ''){
        return res.status(422).json({
            "error": "El campo comentarios es obligatorio",
            "code": "SYNTAX_ERROR"
        });
    }

    next();
}
module.exports = {
    validateSalida,
    validateAusencia
}



/*
Pendiente investigar como usarlo o una libreria alterna a Joi
const salidaEsquma = {//Pendiente investigar como implementarlo bonito con json
    nomina: {
        type: 0, //0 -> number,1 -> text, 2 -> alphanumber, 3-> no validate, 4 -> hour, 5 -> date
        required: true, // true or false,
        field: "nomina"
    },
    auto: {
        type: 3,
        required: true,
        field: "Tipo de auto"
    },
    placa: {
        type: 2,
        required: false,
        field: "Placas"
    },
    motivo: {
        type: 3,
        required: true,
        field: "Motivo de salida"
    },
    acompanantesQTY: {
        type: 3,
        required: false,
        field: "No. Acompañantes"
    },
    tel: {
        type: 1,
        required: true,
        field: "Teléfono"
    },
    regresa: {
        type: 3,
        required: false,
        field: "Regresa"
    },
    hora_salida: {
        type: 4,
        required: true,
        field: "Hora de salida"
    },
    hora_regreso: {
        type: 4,
        required: true,
        field: "Hora de regreso"
    },
    lugar: {
        type: 3,
        required: true,
        field: "A donde vas"
    },
    descripcion: {
        type: 3,
        required: false,
        field: "Descripcion"
    },
    acompanante1: {
        type: 3,
        required: false,
        field: "Acompañante 1"
    },
    acompanante2: {
        type: 3,
        required: false,
        field: "Acompañante 2"
    },
    acompanante3: {
        type: 3,
        required: false,
        field: "Acompañante 3"
    },
    acompanante4: {
        type: 3,
        required: false,
        field: "Acompañante 4"
    },
    acompanante5: {
        type: 3,
        required: false,
        field: "Acompañante 5"
    }
}

*/