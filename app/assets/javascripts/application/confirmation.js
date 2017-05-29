var mumuki = mumuki || {};
(function (mumuki) {
    mumuki.load(function () {
        $('.btn-confirmation').on('click change', function (evt) {
            $.ajax({
                method: 'POST',
                url: $(this).data('confirmation-url')
            });
            return true;
        });
    });
})(mumuki);

