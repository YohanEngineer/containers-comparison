function fetchUsers() {
    $.ajax({
        url: '/api/users',
        type: 'GET',
        success: function (data) {
            const userList = $('#userList');
            userList.empty();
            data.forEach(function (user) {
                userList.append('<div>' + user.name + ' | ' + user.email + '  <button class="btn btn-danger btn-sm deleteBtn" data-id="' + user.id + '">Delete</button> <button class="btn btn-warning btn-sm editBtn" data-id="' + user.id + '">Edit</button></div>');
            });
        },
        error: function (error) {
            console.error('Error fetching users:', error);
        }
    });
}

function addUser(name, email) {
    $.ajax({
        url: '/api/users',
        type: 'POST',
        data: JSON.stringify({ name: name, email: email }),
        contentType: "application/json; charset=utf-8",
        success: function () {
            fetchUsers();
        }
    });
}

function updateUser(id, name, email) {
    $.ajax({
        url: '/api/users',
        type: 'PUT',
        data: JSON.stringify({ id: id, name: name, email: email }),
        contentType: "application/json; charset=utf-8",
        success: function () {
            fetchUsers();
        }
    });
}

function deleteUser(id) {
    $.ajax({
        url: '/api/users/' + id,
        type: 'DELETE',
        success: function () {
            fetchUsers();
        }
    });
}

$('#submitUser').click(function () {
    const userName = $('#userName').val();
    const userEmail = $('#userEmail').val();
    const action = $('#actionSelect').val();
    const userId = $('#userId').val();

    if (action === 'add') {
        addUser(userName, userEmail);
    } else if (action === 'update') {
        updateUser(userId, userName, userEmail);
    }

    $('#userName').val('');
    $('#userId').val('').addClass('d-none');
    $('#actionSelect').val('add');
});

$('#actionSelect').change(function () {
    if ($(this).val() === 'update') {
        $('#userId').removeClass('d-none');
    } else {
        $('#userId').addClass('d-none');
    }
});

$('body').on('click', '.deleteBtn', function () {
    const userId = $(this).data('id');
    deleteUser(userId);
});

$('body').on('click', '.editBtn', function () {
    const userId = $(this).data('id');
    $('#userId').val(userId).removeClass('d-none');
    $('#actionSelect').val('update');
});

fetchUsers();