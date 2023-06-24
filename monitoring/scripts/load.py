import asyncio
import aiohttp
import faker

# Créez une instance de Faker
fake = faker.Faker()

# URL de l'API
url = "http://192.168.1.175:1993/users"

# Combien d'utilisateurs vous voulez créer
num_users = 100

# Création d'une tâche asynchrone pour effectuer une requête POST
async def create_user(session, url, name, email):
    data = {"name": name, "email": email}

    async with session.post(url, json=data) as response:
        if response.status == 200:
            print(f"User {name} ({email}) created successfully.")
        else:
            print(f"Failed to create user {name} ({email}).")

# Création de plusieurs tâches pour effectuer des requêtes POST en parallèle
async def main():
    async with aiohttp.ClientSession() as session:
        tasks = []
        for _ in range(num_users):
            name = fake.name()
            email = fake.email()
            task = asyncio.ensure_future(create_user(session, url, name, email))
            tasks.append(task)

        await asyncio.gather(*tasks)

# Exécution du programme
asyncio.run(main())
