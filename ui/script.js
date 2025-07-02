// UI anzeigen/verstecken basierend auf Nachrichten von Lua
window.addEventListener('message', function (event) {
    const data = event.data;

    if (data.action === 'open') {
        // Texte und Preis aus Lua Config setzen
        document.getElementById('heading1').innerText = data.heading1;
        document.getElementById('heading2').innerText = data.heading2;
        document.querySelector('.rentbutton').innerText = `${data.buttonText}`;
            document.querySelector('.price').innerText = `PRICE: ${data.price}$`;

        document.body.style.display = 'block';
    } else if (data.action === 'close') {
        document.body.style.display = 'none';
    }
});

// DOM bereit
$(function () {
$(document).on('click', '.rentbutton', function () {
    console.log("Rent button clicked");
    $.post(`https://${GetParentResourceName()}/rent`, JSON.stringify({}));
});


    // ESC schließt das UI
    document.addEventListener('keydown', function (event) {
        if (event.key === "Escape") {
            $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({}));
        }
    });
});
