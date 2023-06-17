import React, { useEffect, useState } from 'react';
import { getUsers } from '../Service/apiService';
import UpdateUser from './UpdateUser';
import DeleteUser from './DeleteUser';
import { Table } from 'react-bootstrap';

const UserList = () => {
  const [users, setUsers] = useState([]);

  const fetchUsers = async () => {
    const response = await getUsers();
    setUsers(response.data);
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  return (
    <Table striped bordered hover>
      <thead>
        <tr>
          <th>#</th>
          <th>Name</th>
          <th>Email</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        {users.map(user => (
          <tr key={user.id}>
            <td>{user.id}</td>
            <td>{user.name}</td>
            <td>{user.email}</td>
            <td>
              <UpdateUser user={user} />
              <DeleteUser userId={user.id} />
            </td>
          </tr>
        ))}
      </tbody>
    </Table>
  );
};

export default UserList;
