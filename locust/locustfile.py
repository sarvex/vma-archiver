from random import randint

import requests
from locust import HttpUser, task
from requests.structures import CaseInsensitiveDict

urlArtist = "http://localhost:8080/api/vma/voting/artist"
urlSong = "http://localhost:8080/api/vma/voting/song"
open_voting = "http://localhost:8080/api/vma/voting/open"
count_url = "http://localhost:8080/api/vma/voting/count"


class VmaVoting(HttpUser):
    @task
    def voting(self):
        response = requests.get("http://localhost:8080/api/vma/registry/current")
        open_result = requests.get(open_voting).json()
        print(open_result)
        headers = CaseInsensitiveDict()
        user_id = open_result['id']
        headers["Cookie"] = f"votingId={user_id}"

        for category in response.json():
            print(category["category"])
            print(category)
            if category["type"] == "ARTIST":
                elected = category["artists"][randint(0, len(category['artists']) - 1)]
                resp = requests.post(
                    urlArtist,
                    headers=headers,
                    json={
                        "userId": user_id,
                        "idC": category["id"],
                        "idA": elected["id"]
                    })
                print(resp.status_code)
            if category["type"] in ["SONG", "INSTRUMENTAL"]:
                elected = category["songs"][randint(0, len(category['songs']) - 1)]
                resp = requests.post(
                    urlSong,
                    headers=headers,
                    json={
                        "userId": user_id,
                        "idC": category["id"],
                        "idS": elected["id"]
                    })
                print(resp.status_code)


requests.post(count_url)
