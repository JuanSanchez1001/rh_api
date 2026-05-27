const configCookie = {
maxAge: 15 * 60 * 1000,
httpOnly: true,
sameSite: 'lax',
secure: true
};
async function valiteSession(req, res, next) {
    const validateToken = req.cookies.token;

    if(!validateToken){
        return res.status(500).json({
            "error": "No hay credenciales",
            "code": "WITHOUT_SESSION"
        })
    }else{
        res.cookie('token', validateToken, configCookie);
        next();
    }
}

module.exports = {
    valiteSession
}