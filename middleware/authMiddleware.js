const configCookie = {
maxAge: 15 * 60 * 1000,
httpOnly: true,
sameSite: 'lax',
secure: true
};
const numberRegex = /^\d+$/;
const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[$@$!%*?&])([A-Za-z\d$@$!%*?&]|[^ ]){8,15}$/;

async function valiteSession(req, res, next) {
    const validateToken = req.cookies.token;

    if(!validateToken){
        return res.status(500).json({
            "error": "No hay credenciales",
            "code": "WITHOUT_SESSION"
        });
    }else{
        res.cookie('token', validateToken, configCookie);
        next();
    }
}
async function validateLoginData(req, res, next) {
    const { nomina, password } = req.body;

    if(!numberRegex.test(nomina)){
        return res.status(500).json({
            "error": "Campo nomina es obligatorio y numérico",
            "code": "SYNTAX_ERROR"
        });
    }else if(password == ""){
        return res.status(500).json({
            "error": "Digite su contraseña",
            "code": "SYNTAX_ERROR"
        });
    }else{
        next();
    }
}
async function validateChangePassword(req, res, next) {
    const { nomina, newPassword } = req.query;

    if(!numberRegex.test(nomina)){
        return res.status(500).json({
            "error": "Campo nomina es obligatorio y numérico",
            "code": "SYNTAX_ERROR"
        });
    } else if(!passwordRegex.test(newPassword)){
        return res.status(500).json({
            "error": "Establezca una contraseña segura",
            "code": "SYNTAX_ERROR"
        });
    }else {
        next();
    }
}

module.exports = {
    valiteSession,
    validateLoginData,
    validateChangePassword
}