async function valiteSession(req, res, next) {
    const validateToken = req.cookies.token;

    if(!validateToken){
        return res.status(500).json({
            "error": "No hay credenciales",
            "code": "WITHOUT_SESSION"
        })
    }else{
        next();
    }
}

module.exports = {
    valiteSession
}