import React from 'react';
import { deleteUser } from '../Service/apiService';
import { Button } from 'react-bootstrap';

const DeleteUser = ({ userId }) => {
  const handleDelete = async () => {
    try {
      await deleteUser(userId);
      alert('User deleted');
      // refresh the page
      window.location.reload();
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <Button variant="danger" onClick={handleDelete}>Delete user</Button>
  );
};

export default DeleteUser;
