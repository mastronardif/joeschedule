import docker
import argparse

#python list_dangling_images.py --delete --force
def list_dangling_images():
    client = docker.from_env()

    # List dangling images
    dangling_images = client.images.list(filters={"dangling": True})

    # Print the details of dangling images
    print("Dangling Images:")
    for image in dangling_images:
        print(f"ID: {image.id}, Tags: {image.tags}")

def delete_dangling_images(force=False):
    client = docker.from_env()

    # List dangling images
    dangling_images = client.images.list(filters={"dangling": True})

    # Delete dangling images
    for image in dangling_images:
        print(f"Deleting dangling image: {image.id}, Tags: {image.tags}")
        client.images.remove(image.id, force=force)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="List or delete dangling Docker images.")
    parser.add_argument("--delete", action="store_true", help="Delete dangling images")
    parser.add_argument("--force", action="store_true", help="Force delete images (use with --delete)")

    args = parser.parse_args()

    if args.delete:
        delete_dangling_images(force=args.force)
    else:
        list_dangling_images()
