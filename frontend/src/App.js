import './App.css';
import UserList from './Composant/UserList';
import CreateUser from './Composant/CreateUser';
import { Container } from 'react-bootstrap';
import 'bootstrap/dist/css/bootstrap.min.css';

function App() {
  return (
    <Container className="d-flex flex-column align-items-center" style={{ maxWidth: '800px' }}>
      <h1>Create User</h1>
      <CreateUser />
      <h1>Users</h1>
      <UserList />
    </Container>
  );
}

export default App;
