import React, { useState, useEffect } from 'react';
import { updateUser } from '../Service/apiService';
import { Form, Button } from 'react-bootstrap';

const UpdateUser = ({ user }) => {
  const [name, setName] = useState(user.name);
  const [email, setEmail] = useState(user.email);

  const submitForm = async (e) => {
    e.preventDefault();
    try {
      await updateUser(user.id, { name, email });
      alert('User updated');
      // refresh the page
      window.location.reload();
    } catch (error) {
      console.error(error);
    }
  };

  useEffect(() => {
    setName(user.name);
    setEmail(user.email);
  }, [user]);

  return (
    <Form onSubmit={submitForm}>
      <Form.Group controlId="formBasicName">
        <Form.Label>Name:</Form.Label>
        <Form.Control type="text" value={name} onChange={e => setName(e.target.value)} required />
      </Form.Group>
      <Form.Group controlId="formBasicEmail">
        <Form.Label>Email:</Form.Label>
        <Form.Control type="email" value={email} onChange={e => setEmail(e.target.value)} required />
      </Form.Group>
      <Button variant="primary" type="submit">
        Update user
      </Button>
    </Form>
  );
};

export default UpdateUser;
