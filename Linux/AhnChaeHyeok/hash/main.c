#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <openssl/evp.h>

int main(int argc, char *argv[])
{
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <file>\n", argv[0]);
        return 1;
    }

    const char *filename = argv[1];
    const int buffer_size = 1024;
    unsigned char md5_hash[EVP_MAX_MD_SIZE];
    unsigned char sha1_hash[EVP_MAX_MD_SIZE];

    EVP_MD_CTX *md5_ctx = EVP_MD_CTX_new();
    EVP_MD_CTX *sha1_ctx = EVP_MD_CTX_new();

    if (!md5_ctx || !sha1_ctx) {
        perror("Error creating MD5 and SHA1 contexts");
        return 1;
    }

    if (EVP_DigestInit(md5_ctx, EVP_md5()) != 1 ||
        EVP_DigestInit(sha1_ctx, EVP_sha1()) != 1) {
        perror("Error initializing MD5 and SHA1 digests");
        return 1;
    }

    FILE *file = fopen(filename, "rb");
    if (!file) {
        perror("Error opening file");
        return 1;
    }

    unsigned char buffer[buffer_size];
    size_t bytes_read;
    while ((bytes_read = fread(buffer, 1, buffer_size, file)) > 0) {
        if (EVP_DigestUpdate(md5_ctx, buffer, bytes_read) != 1 ||
            EVP_DigestUpdate(sha1_ctx, buffer, bytes_read) != 1) {
            perror("Error updating MD5 and SHA1 digests");
            return 1;
        }
    }

    fclose(file);

    if (EVP_DigestFinal_ex(md5_ctx, md5_hash, NULL) != 1 ||
        EVP_DigestFinal_ex(sha1_ctx, sha1_hash, NULL) != 1) {
        perror("Error finalizing MD5 and SHA1 digests");
        return 1;
    }

    EVP_MD_CTX_free(md5_ctx);
    EVP_MD_CTX_free(sha1_ctx);

    printf("MD5 hash: ");
    for (int i = 0; i < EVP_MD_size(EVP_md5()); i++) {
        printf("%02x", md5_hash[i]);
    }
    printf("\n");

    printf("SHA1 hash: ");
    for (int i = 0; i < EVP_MD_size(EVP_sha1()); i++) {
        printf("%02x", sha1_hash[i]);
    }
    printf("\n");

    return 0;
}
